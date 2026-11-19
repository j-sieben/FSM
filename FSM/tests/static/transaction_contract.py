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
complete = code.split('procedure complete_event(')[1].split('end complete_event;')[0]
assert complete.index('pop_event') < complete.index('if fsm_event_context.is_empty') < complete.index('if g_auto_commit') < complete.index('commit;')
status = code.split('function set_status(')[1].split('end set_status;')[0]
assert status.index('p_fsm.raise_event') < status.rindex('complete_event(p_fsm)')
assert 'report_failure' in status and 'raise;' in status
assert not re.search(r'\b(?:finish_event|abort_event|g_events|g_depth|g_context)\b', code + spec, re.I)
helper_spec = (root / 'core/packages/fsm_event_context.pks').read_text()
helper_body = (root / 'core/packages/fsm_event_context.pkb').read_text()
assert 'pragma serially_reusable;' in helper_spec and 'pragma serially_reusable;' in helper_body
assert 'accessible by (fsm)' in helper_spec
helper_code = re.sub(r'/\*.*?\*/|--[^\n]*', '', helper_body, flags=re.S)
assert not re.search(r'\bcommit\b|\brollback\b|param\.get_', helper_code, re.I)
install = (root / 'core/install.sql').read_text()
assert install.index('install_package_spec fsm_event_context') < install.index('install_package_spec fsm\n')
assert install.index('install_package_body fsm_event_context') < install.index('install_package_body fsm\n')
assert "'FSM_EVENT_CONTEXT'" in (root / 'core/uninstall.sql').read_text()
for script in ['grant_client_access.sql', 'register_client.sql', 'revoke_client_access.sql', 'uninstall_client.sql']:
    assert 'fsm_event_context' not in (root / 'core' / script).read_text().lower()
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
    assert 'fsm.finish_event(' not in text and 'fsm.abort_event(' not in text, wrapper
print('PASS: internal call-local context, no exposed completion API, outermost FSM commit and lifecycle wiring')
