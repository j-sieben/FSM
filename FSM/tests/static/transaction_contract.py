"""Source-level safety checks; Oracle behavior is covered by tests/transactions."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[2]
body = (root / 'core/packages/fsm.pkb').read_text()
spec = (root / 'core/packages/fsm.pks').read_text()
code = re.sub(r'/\*.*?\*/|--[^\n]*', '', body, flags=re.S)
assert not re.search(r'\block_fsm\b', body + spec, re.I)
assert not re.search(r'\bsavepoint\b|\brollback\b|pragma\s+autonomous_transaction', code, re.I)
assert len(re.findall(r'\bcommit\s*;', code, re.I)) == 1
finish = code.split('procedure finish_event(')[1].split('end finish_event;')[0]
assert re.search(r'if g_depth = 1 and g_auto_commit then\s+commit;', finish)
assert finish.index('confirmed') < finish.index('commit;') < finish.index('g_events.delete')
admission = code.split('function raise_event(')[1].split('end raise_event;')[0]
assert admission.index('for update') < admission.index('select * into l_row') < admission.index('if not allows_event') < admission.index('push_event')
assert admission.index('push_event') < admission.index('p_fsm.refresh_state') < admission.index('log_change')
assert "param.get_boolean('AUTO_COMMIT', 'FSM')" in code
assert 'handle_set_status_error' not in code
for language in ['AMERICAN', 'GERMAN']:
    assert "p_pms_name => 'FSM_TECHNICAL_ERROR'" in (root / 'core/messages' / language / 'create_messages.sql').read_text()
assert 'msg.FSM_TECHNICAL_ERROR' in code
assert 'return C_ERROR;' not in admission
for method in ['persist_retry', 'force_error_status', 'persist', 'retry', 'set_status']:
    segment = re.search(r'\b(?:procedure|function) '+method+r'\(.*?end '+method+r';',code,re.S).group()
    assert 'require_event(p_fsm)' in segment, method
parameters = (root / 'core/scripts/ParameterGroup_FSM.sql').read_text()
assert parameters.index('if l_count = 0 then') < parameters.index('param_admin.edit_parameter(')
assert 'ParameterGroup_FSM' in (root / 'core/install.sql').read_text()
for wrapper in ['sample_app/packages/fsm_req.pkb', 'tests/utplsql/install.sql', 'tests/transactions/install.sql']:
    text = (root / wrapper).read_text()
    assert 'fsm.finish_event(' in text and 'fsm.abort_event(' in text and re.search(r'\braise;', text), wrapper
print('PASS: one outermost commit, no savepoints/autonomous state writes, guarded writes, admission/refresh order and concrete cleanup')
