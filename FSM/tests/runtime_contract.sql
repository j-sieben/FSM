prompt Running FSM runtime contract tests

create or replace type fsm_runtime_test_type under fsm_type();
/

declare
  l_fsm fsm_runtime_test_type;
  l_fsm_id fsm_objects.fsm_id%type := fsm_seq.nextval;
  l_value varchar2(4000);
  l_date date;
  procedure assert_equals(p_actual in varchar2, p_expected in varchar2, p_test in varchar2) as
  begin
    if p_actual = p_expected or p_actual is null and p_expected is null then
      dbms_output.put_line('PASS: ' || p_test);
    else
      raise_application_error(-20000, p_test || ': expected [' || p_expected || '], got [' || p_actual || ']');
    end if;
  end assert_equals;
begin
  insert into fsm_objects(
    fsm_id, fsm_fcl_id, fsm_fsc_id, fsm_fst_id, fsm_validity,
    fsm_last_change_date, fsm_status_change_date, fsm_fms_id, fsm_monitor_status_date)
  values(l_fsm_id, 'FSM', 'MASTER', 'ERROR', fsm.C_OK,
         date '2026-01-01', date '2026-01-02', 'WARN', date '2026-01-03');

  l_fsm := fsm_runtime_test_type(
             l_fsm_id, 'FSM', 'MASTER', 'ERROR', null, null,
             fsm.C_OK, null, 'N');
  select fsm.get_escalation_state(l_fsm_id), fsm.get_escalation_reference_date(l_fsm_id)
    into l_value, l_date from dual;
  assert_equals(l_value, 'WARN', 'runtime returns persisted monitor state');
  assert_equals(to_char(l_date, 'YYYYMMDD'), '20260102', 'STATUS escalation uses status-change date');
  assert_equals(l_fsm.get_actual_status(), 'ERROR', 'type delegates actual status');
  assert_equals(l_fsm.get_validity(), to_char(fsm.C_OK), 'type exposes validity');

  l_fsm.notify('FSM_SUCCESS');
  select fsl_msg_id into l_value from fsm_log
   where fsl_id = (select max(fsl_id) from fsm_log where fsl_fsm_id = l_fsm_id);
  assert_equals(l_value, 'FSM_SUCCESS', 'notify persists the requested message');

  fsm.drop_object(l_fsm_id);
  select count(*) into l_value from fsm_objects where fsm_id = l_fsm_id;
  assert_equals(l_value, '0', 'drop_object removes the runtime projection');
  rollback;
exception when others then rollback; raise;
end;
/

drop type fsm_runtime_test_type;
