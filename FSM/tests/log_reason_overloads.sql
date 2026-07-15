set serveroutput on
whenever sqlerror exit failure rollback

create or replace type fsm_reason_test_type under fsm_type();
/

declare
  l_fsm fsm_reason_test_type;
  l_fsm_id fsm_objects.fsm_id%type := fsm_seq.nextval;
  l_reason message_type;
  l_expected_args msg_args := msg_args('GET', '/unknown');
  l_expected_args_char msg_args_char;
  l_reason_msg_id fsm_log.fsl_reason_msg_id%type;
  l_reason_msg_args fsm_log.fsl_reason_msg_args%type;

  procedure assert_equals(
    p_actual in varchar2,
    p_expected in varchar2,
    p_test in varchar2)
  as
  begin
    if p_actual = p_expected or p_actual is null and p_expected is null then
      dbms_output.put_line('PASS: ' || p_test);
    else
      raise_application_error(
        -20000,
        p_test || ': expected [' || p_expected || '], got [' || p_actual || ']');
    end if;
  end assert_equals;

  procedure assert_args_equal(
    p_actual in msg_args_char,
    p_expected in msg_args_char,
    p_test in varchar2)
  as
  begin
    if p_actual is null or p_expected is null or p_actual.count != p_expected.count then
      raise_application_error(-20000, p_test || ': argument count differs');
    end if;

    for i in 1 .. p_expected.count loop
      if p_actual(i) != p_expected(i) then
        raise_application_error(-20000, p_test || ': argument ' || i || ' differs');
      end if;
    end loop;

    dbms_output.put_line('PASS: ' || p_test);
  end assert_args_equal;

  procedure read_latest_reason
  as
  begin
    select fsl_reason_msg_id, fsl_reason_msg_args
      into l_reason_msg_id, l_reason_msg_args
      from fsm_log
     where fsl_id = (
             select max(fsl_id)
               from fsm_log
              where fsl_fsm_id = l_fsm_id);
  end read_latest_reason;
begin
  insert into fsm_objects(
    fsm_id, fsm_fcl_id, fsm_fsc_id, fsm_fst_id,
    fsm_validity, fsm_last_change_date, fsm_status_change_date)
  values(
    l_fsm_id, 'FSM', 'MASTER', 'ERROR',
    fsm.C_OK, sysdate, sysdate);

  l_fsm := fsm_reason_test_type(
             l_fsm_id, 'FSM', 'MASTER', 'ERROR', null, null,
             fsm.C_OK, null, 'N');

  l_fsm.log_reason('LEGACY', msg_args('legacy'));
  l_fsm.notify('FSM_SUCCESS');
  read_latest_reason;
  assert_equals(
    l_reason_msg_id,
    'FSM_REASON_LEGACY',
    'string overload adds the FSM class prefix');

  l_reason := pit.get_message(
                p_message_name => 'FSM_SUCCESS');
  l_reason.message_name := 'INREST_UNKNOWN_ENDPOINT';
  l_reason.message_args := l_expected_args;
  l_expected_args_char := pit_util.cast_to_msg_args_char(l_reason.message_args);

  l_fsm.log_reason(l_reason);
  l_fsm.notify('FSM_SUCCESS');
  read_latest_reason;
  assert_equals(
    l_reason_msg_id,
    'INREST_UNKNOWN_ENDPOINT',
    'message_type overload preserves the qualified message ID');
  assert_args_equal(
    l_reason_msg_args,
    l_expected_args_char,
    'message_type overload preserves message arguments');

  l_fsm.notify('FSM_SUCCESS');
  read_latest_reason;
  assert_equals(
    l_reason_msg_id,
    null,
    'successful log_change clears the transient reason ID');
  if l_reason_msg_args is null then
    dbms_output.put_line('PASS: a later log entry does not inherit reason arguments');
  else
    raise_application_error(-20000, 'a later log entry inherited reason arguments');
  end if;

  rollback;
end;
/

drop type fsm_reason_test_type;
