"""Check the source contract without an Oracle target. Run from any directory."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[2]
core = root / 'core'
tables = sorted((core / 'tables').glob('*.tbl'))
assert len(tables) == 10
for table in tables:
    name = table.stem
    source = table.read_text()
    body = source.split('create table ' + name)[1].split('constraint pk_')[0]
    columns = re.findall(r'^\s*([a-z]+_[a-z_]+)\s+(?:&|number|varchar2|timestamp|date|clob|msg_args_char|interval)', body, re.M)
    view = (core / 'views' / (name + '_tv.vw')).read_text()
    sql = re.sub(r'/\*.*?\*/', '', view, flags=re.S).split(';')[0].strip()
    expected = r'create or replace view ' + name + r'_tv as\s+select\s+' + r'\s*,\s*'.join(columns) + r'\s+from ' + name
    assert re.fullmatch(expected, sql, re.I), name + ': exact projection'
    for column in columns:
        assert f'comment on column {name}_tv.{column} ' in view
    for script, line in {
        'install.sql': f'@&tools.install_view {name}_tv',
        'grant_client_access.sql': f'@&tool_dir.grant_access_with_grant_option.sql read {name}_tv',
        'register_client.sql': f'@&tool_dir.create_synonym.sql {name}_tv',
        'revoke_client_access.sql': f'@&tool_dir.revoke_access.sql read {name}_tv',
        'uninstall.sql': "'" + name.upper() + "_TV'",
        'uninstall_client.sql': "'" + name.upper() + "_TV'",
    }.items():
        assert line in (core / script).read_text(), (script, name)
    install = (core / 'install.sql').read_text()
    assert install.index('Align Table Definitions') < install.index(f'@&tools.install_view {name}_tv') < install.index('prompt &h2.Create Views')
    print(f'PASS: {name}_tv ({len(columns)} columns), comments and lifecycle')
assert len(list((core / 'views').glob('*_tv.vw'))) == len(tables)
print('PASS: complete core table inventory; no expressions, joins, filters or language dependencies')
