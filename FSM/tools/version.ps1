# Resolve installation identity or export a committed release. PowerShell 5.1+.
param(
    [Parameter(Mandatory = $true)][ValidateSet('resolve', 'export')][string]$Command,
    [string]$Destination
)
$ErrorActionPreference = 'Stop'
$FsmDir = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))

function Invoke-Git {
    param([string[]]$GitArgs)
    $result = & git -C $FsmDir @GitArgs 2>$null
    if ($LASTEXITCODE -ne 0) { throw "Git failed: $($GitArgs -join ' ')" }
    return ($result -join "`n").Trim()
}

try {
    $checkout = $false
    try { $root = Invoke-Git @('rev-parse', '--show-toplevel') }
    catch {
        $parent = [IO.DirectoryInfo]$FsmDir
        while ($null -ne $parent) {
            if (Test-Path (Join-Path $parent.FullName '.git')) {
                throw 'Cannot inspect the Git checkout; install/fix Git first.'
            }
            $parent = $parent.Parent
        }
        $root = $null
    }
    if ($root) {
        try {
            $null = Invoke-Git @('ls-files', '--error-unmatch', 'fsm.sh')
            $checkout = $true
        } catch {
            if ([IO.Path]::GetFullPath($root) -eq [IO.Directory]::GetParent($FsmDir).FullName) {
                throw 'FSM sources are not tracked in this checkout.'
            }
        }
    }
    if ($checkout) {
        if ((Invoke-Git @('rev-parse', '--is-shallow-repository')) -ne 'false') {
            throw 'Full Git history required; fetch the complete history first.'
        }
        if (Invoke-Git @('status', '--porcelain', '--untracked-files=all')) {
            throw 'Local changes found; commit or remove them before installing/exporting.'
        }
        $commit = Invoke-Git @('rev-parse', 'HEAD')
        $base = Invoke-Git @('show', "${commit}:VERSION")
        if ($base -cnotmatch '\A(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\z') {
            throw 'VERSION must contain Major.Minor, for example 1.0.'
        }
        $count = Invoke-Git @('rev-list', '--count', $commit)
        $version = "$base.$count"
    } else {
        $metadata = Join-Path $FsmDir 'install_scripts/release-version.txt'
        if (-not (Test-Path $metadata -PathType Leaf)) {
            throw 'No Git checkout or prepared release metadata found.'
        }
        $lines = [IO.File]::ReadAllLines($metadata)
        if ($lines.Count -ne 2) {
            throw 'Release metadata must contain exactly version and commit on two lines.'
        }
        $version, $commit = $lines
    }
    if ($version.Length -gt 40 -or $version -cnotmatch '\A(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.[1-9][0-9]*\z') {
        throw 'Invalid version; expected Major.Minor.CommitCount.'
    }
    if ($commit -cnotmatch '\A([0-9a-f]{40}|[0-9a-f]{64})\z') {
        throw 'Invalid full Git commit hash.'
    }
    if ($Command -eq 'export') {
        if (-not $checkout) { throw 'Export requires a clean, complete Git checkout.' }
        if (-not $Destination) { throw 'Export requires a ZIP destination.' }
        $destinationPath = [IO.Path]::GetFullPath($Destination)
        if (Test-Path $destinationPath) { throw 'Destination already exists.' }
        $prefix = Invoke-Git @('rev-parse', '--show-prefix')
        $entryName = "${prefix}install_scripts/release-version.txt"
        $tracked = $false
        try {
            $null = Invoke-Git @('cat-file', '-e', "${commit}:${entryName}")
            $tracked = $true
        } catch { }
        if ($tracked) { throw 'Release metadata must not be committed to Git.' }
        $temporary = [IO.Path]::GetTempFileName()
        try {
            $null = Invoke-Git @('-C', $root, 'archive', '--format=zip', "--output=$temporary", $commit)
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $archive = [IO.Compression.ZipFile]::Open($temporary, [IO.Compression.ZipArchiveMode]::Update)
            try {
                $entry = $archive.CreateEntry($entryName)
                $writer = New-Object IO.StreamWriter($entry.Open(), (New-Object Text.UTF8Encoding($false)))
                try { $writer.Write("$version`n$commit`n") } finally { $writer.Dispose() }
            } finally { $archive.Dispose() }
            # File.Move refuses overwriting, including a concurrent new file.
            [IO.File]::Move($temporary, $destinationPath)
        } finally {
            if (Test-Path $temporary) { Remove-Item -LiteralPath $temporary }
        }
    }
    Write-Output "$version $commit"
    exit 0
} catch {
    [Console]::Error.WriteLine("ERROR: $($_.Exception.Message)")
    exit 1
}
