-- Session B: @concurrent_b.sql <ID printed by A> ADVANCE
-- Repeat A with a fresh ID, then use START_ONLY to test rejection after waiting.
set serveroutput on
whenever sqlerror exit failure rollback
begin dbms_session.reset_package; end;
/
declare
  l_fsm fsm_tx_type := fsm_tx_type(&1., 'FTX', 'MASTER', 'START', null, null, fsm.C_OK, 'ADVANCE:START_ONLY', 'N');
  l_result number;
  l_rejected boolean := false;
  l_start timestamp := systimestamp;
begin
  begin
    l_result := l_fsm.raise_event('&2.');
  exception when others then
    if '&2.' != 'START_ONLY' or sqlcode != -20003 then raise; end if;
    l_rejected := true;
  end;
  if '&2.' = 'ADVANCE' and l_fsm.fsm_fst_id != 'DONE' then
    raise_application_error(-20091, 'Decision did not use refreshed MIDDLE state');
  end if;
  if '&2.' = 'START_ONLY' and not l_rejected then
    raise_application_error(-20091, 'Event was not rejected after competing transition');
  end if;
  dbms_output.put_line('PASS: &2. elapsed ' || (systimestamp - l_start));
  rollback;
end;
/
