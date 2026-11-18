-- Run after install.sql, in dedicated session A. Output ID to session B.
set serveroutput on
whenever sqlerror exit failure rollback
variable test_fsm_id number
begin
  param.set_boolean('AUTO_COMMIT', 'FSM', false);
  commit;
  dbms_session.reset_package;
end;
/
declare
  l_fsm fsm_tx_type := fsm_tx_type(null, 'FTX', 'MASTER', null, null, null, fsm.C_OK, null, 'N');
begin
  fsm.initialize(l_fsm);
  :test_fsm_id := l_fsm.fsm_id;
  commit;
end;
/
print test_fsm_id
prompt Start concurrent_b.sql with this ID in session B during the next 30 seconds.
declare
  l_fsm fsm_tx_type := fsm_tx_type(:test_fsm_id, 'FTX', 'MASTER', 'START', null, null, fsm.C_OK, 'ADVANCE:START_ONLY', 'N');
  l_result number;
begin
  l_result := fsm.raise_event(l_fsm, 'ADVANCE');
  l_result := l_fsm.set_status('MIDDLE');
  dbms_session.sleep(30);
  fsm.finish_event(l_fsm);
  commit;
exception when others then
  fsm.abort_event(l_fsm, dbms_utility.format_error_stack, dbms_utility.format_error_backtrace);
  rollback;
  raise;
end;
/
