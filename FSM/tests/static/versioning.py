"""Exercise Git, offline releases and the Unix installer without a database."""

import os
import shutil
import subprocess
import tempfile
import unittest
import zipfile
from pathlib import Path


SOURCE = Path(__file__).resolve().parents[3]


class VersioningTest(unittest.TestCase):
    engine = 'bash'
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="fsm version test ")
        self.base = Path(self.temp.name)
        self.repo = self.base / "repository with spaces"
        self.repo.mkdir()
        for name in ["VERSION", ".gitignore", "FSM/fsm.sh", "FSM/tools/version.sh", "FSM/tools/version.ps1"]:
            target = self.repo / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(SOURCE / name, target)
        self.git("init", "-q")
        self.git("config", "user.email", "test@example.invalid")
        self.git("config", "user.name", "Version test")
        self.commit("initial")
        self.bin = self.base / "bin"
        self.bin.mkdir()
        self.capture = self.base / "sqlplus.json"
        fake = self.bin / "sqlplus"
        fake.write_text(
            '#!/bin/sh\npwd > "$CAPTURE.cwd"\ncat > "$CAPTURE"\n'
            'exit "${SQL_EXIT:-0}"\n'
        )
        fake.chmod(0o755)
        self.env = dict(os.environ, PATH=f"{self.bin}{os.pathsep}{os.environ['PATH']}",
                        CAPTURE=str(self.capture), FSM_OWNER="FSM", FSM_OWNER_PW="dummy",
                        FSM_SERVICE="TEST", FSM_LOG_DIR=str(self.base / "logs"))

    def tearDown(self):
        self.temp.cleanup()

    def git(self, *args):
        return subprocess.check_output(
            ["git", "-C", str(self.repo), "-c", "core.hooksPath=/dev/null", *args],
            stderr=subprocess.PIPE, text=True
        ).strip()

    def commit(self, message):
        self.git("add", ".")
        self.git("commit", "-qm", message)

    def helper(self, *args, repo=None):
        tools = (repo or self.repo) / "FSM/tools"
        command = (["pwsh", "-NoProfile", "-File", str(tools / "version.ps1")]
                   if self.engine == 'pwsh' else ["bash", str(tools / "version.sh")])
        return subprocess.run(
            [*command, *args],
            capture_output=True, text=True, cwd=self.base
        )

    def install(self, repo=None, **env):
        return subprocess.run(
            ["bash", str((repo or self.repo) / "FSM/fsm.sh"), "install"],
            capture_output=True, text=True, cwd=self.base, env=dict(self.env, **env)
        )

    def test_product_count_changes_for_other_files(self):
        self.assertEqual(self.helper("resolve").stdout.split(), ["1.0.1", self.git("rev-parse", "HEAD")])
        (self.repo / "other-package.txt").write_text("change outside FSM package")
        self.commit("other package")
        expected = ["1.0.2", self.git("rev-parse", "HEAD")]
        self.assertEqual(self.helper("resolve").stdout.split(), expected)
        self.assertEqual(self.helper("resolve").stdout.split(), expected)
        (self.repo / "VERSION").write_text("2.1\n")
        self.commit("major/minor")
        self.assertEqual(self.helper("resolve").stdout.split()[0], "2.1.3")

    def test_installer_arguments_cwd_and_failure(self):
        result = self.install(SQL_EXIT="7")
        self.assertEqual(result.returncode, 7, result.stderr)
        self.assertEqual(Path(Path(str(self.capture) + '.cwd').read_text().strip()).resolve(), (self.repo / "FSM").resolve())
        self.assertIn(f'@"{self.repo}/FSM/install_scripts/install.sql" FSM GERMAN 1.0.1 {self.git("rev-parse", "HEAD")}', self.capture.read_text())

    def test_count_includes_merged_branch_commits(self):
        main = self.git("symbolic-ref", "--short", "HEAD")
        self.git("checkout", "-qb", "topic")
        (self.repo / "topic.txt").write_text("topic change")
        self.commit("topic")
        self.git("checkout", "-q", main)
        (self.repo / "main.txt").write_text("main change")
        self.commit("main")
        self.git("merge", "--no-ff", "-qm", "merge topic", "topic")
        self.assertEqual(self.helper("resolve").stdout.split()[0], "1.0.4")
        self.assertEqual(self.git("rev-list", "--first-parent", "--count", "HEAD"), "3")

    def test_dirty_checkout_never_connects(self):
        for staged in [False, True]:
            with self.subTest(staged=staged):
                (self.repo / "untracked.txt").write_text("local change")
                if staged:
                    self.git("add", ".")
                result = self.install()
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("Local changes", result.stderr)
                self.assertFalse(self.capture.exists())

    def test_shallow_checkout_never_connects(self):
        shallow = self.base / "shallow"
        subprocess.run(["git", "clone", "-q", "--depth=1", self.repo.as_uri(), str(shallow)], check=True)
        result = self.install(repo=shallow)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Full Git history", result.stderr)
        self.assertFalse(self.capture.exists())

    def test_invalid_version_never_connects(self):
        (self.repo / "VERSION").write_text("1.0'; drop table example; --\n")
        self.commit("invalid version")
        result = self.install()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("VERSION must contain", result.stderr)
        self.assertFalse(self.capture.exists())

    def test_offline_release_and_stale_metadata(self):
        release = self.base / "release.zip"
        result = self.helper("export", str(release))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git("status", "--porcelain"), "")
        self.assertNotEqual(self.helper("export", str(release)).returncode, 0)
        identity = result.stdout.split()
        offline = self.base / "offline release"
        with zipfile.ZipFile(release) as package:
            self.assertIsNone(package.testzip())
            package.extractall(offline)
        self.assertEqual(self.helper("resolve", repo=offline).stdout.split(), identity)
        result = self.install(repo=offline)
        self.assertEqual(result.returncode, 0, result.stderr)
        # Prove the production installer needs neither Python nor Git offline.
        offline_bin = self.base / 'offline-bin'
        offline_bin.mkdir()
        for tool in ['bash', 'dirname', 'tee', 'cat', 'mkdir']:
            (offline_bin / tool).symlink_to(shutil.which(tool))
        shutil.copy2(self.bin / 'sqlplus', offline_bin / 'sqlplus')
        result = self.install(repo=offline, PATH=str(offline_bin))
        self.assertEqual(result.returncode, 0, result.stderr)
        metadata = offline / "FSM/install_scripts/release-version.txt"
        metadata.write_text("1.0.1\nnot-a-commit\n")
        self.assertNotEqual(self.helper("resolve", repo=offline).returncode, 0)
        metadata.unlink()
        self.assertIn("No Git checkout", self.helper("resolve", repo=offline).stderr)
        stale = self.repo / "FSM/install_scripts/release-version.txt"
        stale.parent.mkdir(parents=True)
        stale.write_text("9.9.999\n" + "a" * 40 + "\n")
        self.assertEqual(self.helper("resolve").stdout.split(), identity)
        (self.repo / "VERSION").write_text("1.1\n")
        self.assertNotEqual(self.helper("resolve").returncode, 0)


@unittest.skipUnless(shutil.which('pwsh'), 'PowerShell is not installed on this test host')
class PowerShellVersioningTest(VersioningTest):
    engine = 'pwsh'


if __name__ == "__main__":
    unittest.main()
