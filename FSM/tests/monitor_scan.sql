set serveroutput on
whenever sqlerror exit failure rollback

create or replace type fsm_monitor_test_type under fsm_type();
/

declare
  C_TEST_CLASS constant pit_util.ora_name_type := 'MONITOR_TEST';
  C_TEST_STATUS constant pit_util.ora_name_type := 'WAITING';

  l_findings fsm_monitor.finding_tab;
  l_fsm_id fsm_objects.fsm_id%type := fsm_seq.nextval;
  l_scan_date date := trunc(sysdate) + 12 / 24;
  l_monitor_status fsm_objects.fsm_fms_id%type;
  l_log_count binary_integer;

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

  procedure cleanup
  as
  begin
    delete from fsm_objects where fsm_id = l_fsm_id;
    fsm_admin.delete_class(C_TEST_CLASS, true);
    pit_admin.delete_message_group(C_TEST_CLASS, true);
    commit;
  exception
    when others then
      rollback;
  end cleanup;
begin
  fsm_admin.merge_class(
    p_fcl_id => C_TEST_CLASS,
    p_fcl_type_name => 'FSM_MONITOR_TEST_TYPE',
    p_fcl_name => 'Monitor test',
    p_fcl_description => 'Temporary class for FSM_MONITOR tests');

  fsm_admin.merge_status_group(
    p_fsg_id => 'OPEN',
    p_fsg_fcl_id => C_TEST_CLASS,
    p_fsg_name => 'Open',
    p_fsg_description => 'Temporary monitor test group');

  fsm_admin.merge_status(
    p_fst_id => C_TEST_STATUS,
    p_fst_fcl_id => C_TEST_CLASS,
    p_fst_fsg_id => 'OPEN',
    p_fst_name => 'Waiting',
    p_fst_description => 'Temporary monitored status',
    p_fst_severity => fsm.C_STORY_STEP,
    p_fst_msg_id => 'MONITOR_TEST_WAITING',
    p_fst_warn_interval => interval '10' minute,
    p_fst_alert_interval => interval '20' minute,
    p_fst_escalation_basis => 'STATUS',
    p_fst_initial_status => true);

  insert into fsm_objects(
    fsm_id, fsm_fcl_id, fsm_fsc_id, fsm_fst_id,
    fsm_validity, fsm_last_change_date, fsm_status_change_date)
  values(
    l_fsm_id, C_TEST_CLASS, 'MASTER', C_TEST_STATUS,
    fsm.C_OK, l_scan_date - 30 / 1440, l_scan_date - 30 / 1440);
  commit;

  fsm_monitor.scan(C_TEST_CLASS, l_scan_date, l_findings);
  assert_equals(to_char(l_findings.count), '2', 'OK to ALERT returns two findings');
  assert_equals(l_findings(1).signaled_fms_id, fsm_monitor.C_WARN, 'WARN is signaled first');
  assert_equals(l_findings(2).signaled_fms_id, fsm_monitor.C_ALERT, 'ALERT is signaled second');
  assert_equals(
    to_char(l_findings(1).detected_at, 'YYYYMMDDHH24MISS'),
    to_char(l_findings(2).detected_at, 'YYYYMMDDHH24MISS'),
    'findings from one scan share their detection time');

  select fsm_fms_id
    into l_monitor_status
    from fsm_objects
   where fsm_id = l_fsm_id;
  assert_equals(l_monitor_status, fsm_monitor.C_ALERT, 'highest status is persisted');

  select count(*)
    into l_log_count
    from fsm_log
   where fsl_fsm_id = l_fsm_id
     and fsl_msg_id = 'FSM_MONITOR_STATUS_CHANGED';
  assert_equals(to_char(l_log_count), '2', 'both upward findings are logged');

  fsm_monitor.scan(C_TEST_CLASS, l_scan_date, l_findings);
  assert_equals(to_char(l_findings.count), '0', 'unchanged ALERT produces no finding');

  update fsm_objects
     set fsm_last_change_date = l_scan_date,
         fsm_status_change_date = l_scan_date
   where fsm_id = l_fsm_id;
  commit;

  fsm_monitor.scan(C_TEST_CLASS, l_scan_date + 1 / 1440, l_findings);
  assert_equals(to_char(l_findings.count), '1', 'ALERT to OK returns one finding');
  assert_equals(l_findings(1).signaled_fms_id, fsm_monitor.C_OK, 'recovery signals OK');

  cleanup;
exception
  when others then
    cleanup;
    raise;
end;
/

drop type fsm_monitor_test_type;
