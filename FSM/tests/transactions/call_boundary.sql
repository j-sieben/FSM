-- Separate anonymous blocks are deliberately separate server calls. Run after
-- mode.sql TRUE in the disposable transaction-suite owner.
variable abandoned_fsm_id number

declare
  l_fsm fsm_tx_type := fsm_tx_type(null, 'FTX', 'MASTER', null, null, null, fsm.C_OK, null, 'N');
  l_result number;
begin
  fsm.initialize(l_fsm);
  :abandoned_fsm_id := l_fsm.fsm_id;
  commit;
  begin
    l_result := fsm.raise_event(l_fsm, 'ADVANCE');
    l_fsm.log_reason('SHOULD_EXPIRE', msg_args('not for the next call'));
    raise_application_error(-20081, 'Simulated concrete-handler failure before SET_STATUS');
  exception when others then
    if sqlcode != -20081 then raise; end if;
    rollback;
    -- End this server call. No public context cleanup is required.
  end;
end;
/

declare
  l_fsm fsm_tx_type := fsm_tx_type(:abandoned_fsm_id, 'FTX', 'MASTER', 'START', 'START', 'ADVANCE', fsm.C_OK, 'ADVANCE', 'N');
  l_result number;
  l_rejected boolean := false;
  l_count number;
begin
  begin
    l_result := l_fsm.set_status('MIDDLE');
  exception when others then
    if sqlcode != -20001 then raise; end if;
    l_rejected := true;
  end;
  if not l_rejected then
    raise_application_error(-20090, 'Event frame survived the previous server call');
  end if;
  l_result := l_fsm.raise_event('ADVANCE');
  if fsm_tx_probe.visible_status(l_fsm.fsm_id) != 'MIDDLE' then
    raise_application_error(-20090, 'New root event did not complete independently');
  end if;
  select count(*) into l_count from fsm_log
   where fsl_fsm_id = l_fsm.fsm_id and fsl_reason_msg_id = 'FTX_REASON_SHOULD_EXPIRE';
  if l_count != 0 then
    raise_application_error(-20090, 'Pending reason survived server-call boundary');
  end if;
  dbms_output.put_line('PASS: abandoned context expires without resetting the FSM package');
end;
/

begin
  begin
    execute immediate 'begin fsm_event_context.clear_all; end;';
    raise_application_error(-20090, 'Internal context package was directly callable');
  exception when others then
    if sqlcode != -6550 or instr(sqlerrm, 'PLS-00904') = 0 then raise; end if;
    dbms_output.put_line('PASS: ACCESSIBLE BY restricts context operations to FSM');
  end;
end;
/
