prompt Running FSM_MONITOR tests

create or replace type fsm_monitor_test_type under fsm_type();
/

declare
  C_TEST_CLASS constant pit_util.ora_name_type := 'MONITOR_TEST';
  C_STATUS_BASIS constant pit_util.ora_name_type := 'WAIT_STATUS';
  C_EVENT_BASIS constant pit_util.ora_name_type := 'WAIT_EVENT';
  C_SCAN_DATE constant date := date '2026-01-15' + 12 / 24;
  l_findings fsm_monitor.finding_tab;
  l_fsm_id fsm_objects.fsm_id%type := fsm_seq.nextval;
  l_value varchar2(4000);
  l_date date;
  l_count binary_integer;

  procedure assert_equals(p_actual in varchar2, p_expected in varchar2, p_test in varchar2) as
  begin
    if p_actual = p_expected or p_actual is null and p_expected is null then
      dbms_output.put_line('PASS: ' || p_test);
    else
      raise_application_error(-20000, p_test || ': expected [' || p_expected || '], got [' || p_actual || ']');
    end if;
  end assert_equals;

  procedure assert_date(p_actual in date, p_expected in date, p_test in varchar2) as
  begin
    assert_equals(to_char(p_actual, 'YYYYMMDDHH24MISS'), to_char(p_expected, 'YYYYMMDDHH24MISS'), p_test);
  end assert_date;

  procedure reset_object(
    p_fms_id in varchar2,
    p_age_minutes in number,
    p_status_age_minutes in number default null,
    p_status in varchar2 default C_STATUS_BASIS) as
  begin
    update fsm_objects
       set fsm_fst_id = p_status,
           fsm_fms_id = p_fms_id,
           fsm_monitor_status_date = C_SCAN_DATE - 1,
           fsm_last_change_date = C_SCAN_DATE - p_age_minutes / 1440,
           fsm_status_change_date = C_SCAN_DATE - coalesce(p_status_age_minutes, p_age_minutes) / 1440
     where fsm_id = l_fsm_id;
    delete from fsm_log where fsl_fsm_id = l_fsm_id;
    commit;
  end reset_object;

  procedure scan_and_assert(
    p_previous in varchar2,
    p_age_minutes in number,
    p_expected_count in number,
    p_expected_current in varchar2,
    p_test in varchar2,
    p_status_age_minutes in number default null,
    p_status in varchar2 default C_STATUS_BASIS,
    p_scan_date in date default C_SCAN_DATE) as
  begin
    reset_object(p_previous, p_age_minutes, p_status_age_minutes, p_status);
    fsm_monitor.scan(C_TEST_CLASS, p_scan_date, l_findings);
    assert_equals(to_char(l_findings.count), to_char(p_expected_count), p_test);
    select fsm_fms_id into l_value from fsm_objects where fsm_id = l_fsm_id;
    assert_equals(l_value, p_expected_current, p_test || ' persists current state');
  end scan_and_assert;

  procedure cleanup as
  begin
    delete from fsm_objects where fsm_id = l_fsm_id;
    fsm_admin.delete_class(C_TEST_CLASS, true);
    pit_admin.delete_message_group(C_TEST_CLASS, true);
    commit;
  exception when others then rollback;
  end cleanup;
begin
  fsm_admin.merge_class(C_TEST_CLASS, 'FSM_MONITOR_TEST_TYPE', 'Monitor test', 'Temporary FSM_MONITOR test class');
  fsm_admin.merge_status_group('OPEN', C_TEST_CLASS, 'Open', 'Temporary monitor test group');
  fsm_admin.merge_status(
    p_fst_id => C_STATUS_BASIS, p_fst_fcl_id => C_TEST_CLASS, p_fst_fsg_id => 'OPEN',
    p_fst_name => 'Waiting by status', p_fst_description => 'Temporary monitored status',
    p_fst_severity => fsm.C_STORY_STEP, p_fst_msg_id => 'MONITOR_TEST_WAIT_STATUS',
    p_fst_warn_interval => interval '10' minute, p_fst_alert_interval => interval '20' minute,
    p_fst_escalation_basis => 'STATUS', p_fst_initial_status => true);
  fsm_admin.merge_status(
    p_fst_id => C_EVENT_BASIS, p_fst_fcl_id => C_TEST_CLASS, p_fst_fsg_id => 'OPEN',
    p_fst_name => 'Waiting by event', p_fst_description => 'Temporary event monitored status',
    p_fst_severity => fsm.C_STORY_STEP, p_fst_msg_id => 'MONITOR_TEST_WAIT_EVENT',
    p_fst_warn_interval => interval '10' minute, p_fst_alert_interval => interval '20' minute,
    p_fst_escalation_basis => 'EVENT');

  insert into fsm_objects(
    fsm_id, fsm_fcl_id, fsm_fsc_id, fsm_fst_id,
    fsm_validity, fsm_last_change_date, fsm_status_change_date)
  values(l_fsm_id, C_TEST_CLASS, 'MASTER', C_STATUS_BASIS, fsm.C_OK, C_SCAN_DATE, C_SCAN_DATE);
  commit;

  scan_and_assert('OK', 5, 0, 'OK', 'OK to OK');
  scan_and_assert('OK', 10, 1, 'WARN', 'OK to WARN at exact boundary');
  assert_equals(l_findings(1).signaled_fms_id, 'WARN', 'WARN signal is returned');
  assert_date(l_findings(1).monitor_status_date, C_SCAN_DATE, 'WARN effective date is threshold');

  scan_and_assert('OK', 20, 2, 'ALERT', 'OK to ALERT at exact boundary');
  assert_equals(l_findings(1).signaled_fms_id, 'WARN', 'WARN is signaled first');
  assert_equals(l_findings(2).signaled_fms_id, 'ALERT', 'ALERT is signaled second');
  assert_equals(l_findings(1).previous_fms_id, 'OK', 'first upward edge starts at OK');
  assert_equals(l_findings(2).previous_fms_id, 'WARN', 'second upward edge starts at WARN');
  assert_equals(l_findings(2).current_fms_id, 'ALERT', 'finding exposes final current state');
  assert_equals(to_char(l_findings(1).detected_at, 'YYYYMMDDHH24MISS'),
                to_char(l_findings(2).detected_at, 'YYYYMMDDHH24MISS'),
                'one scan uses one detection timestamp');
  select count(*) into l_count from fsm_log
   where fsl_fsm_id = l_fsm_id and fsl_msg_id = 'FSM_MONITOR_STATUS_CHANGED';
  assert_equals(to_char(l_count), '2', 'both upward edges are logged');

  fsm_monitor.scan(C_TEST_CLASS, C_SCAN_DATE, l_findings);
  assert_equals(to_char(l_findings.count), '0', 'unchanged ALERT has no edge');
  scan_and_assert('WARN', 15, 0, 'WARN', 'WARN to WARN');
  scan_and_assert('WARN', 20, 1, 'ALERT', 'WARN to ALERT');
  assert_equals(l_findings(1).signaled_fms_id, 'ALERT', 'WARN to ALERT signals ALERT only');
  scan_and_assert('WARN', 5, 1, 'OK', 'WARN to OK');
  scan_and_assert('ALERT', 20, 0, 'ALERT', 'ALERT to ALERT');
  scan_and_assert('ALERT', 15, 1, 'WARN', 'ALERT to WARN');
  scan_and_assert('ALERT', 5, 1, 'OK', 'ALERT to OK');

  scan_and_assert('OK', 5, 0, 'OK', 'EVENT basis uses recent activity',
                  p_status_age_minutes => 25, p_status => C_EVENT_BASIS);
  scan_and_assert('OK', 20, 2, 'ALERT', 'EVENT basis uses last activity at alert boundary',
                  p_status_age_minutes => 5, p_status => C_EVENT_BASIS);

  update fsm_status set fst_warn_interval = null, fst_alert_interval = null
   where fst_id = C_EVENT_BASIS and fst_fcl_id = C_TEST_CLASS;
  commit;
  scan_and_assert('WARN', 100, 1, 'OK', 'missing intervals recover to OK', p_status => C_EVENT_BASIS);

  reset_object('OK', 30);
  update fsm_objects set fsm_last_change_date = null, fsm_status_change_date = null where fsm_id = l_fsm_id;
  commit;
  fsm_monitor.scan(C_TEST_CLASS, C_SCAN_DATE, l_findings);
  assert_equals(to_char(l_findings.count), '0', 'missing reference date remains OK');

  reset_object('OK', 30);
  fsm_monitor.scan('CLASS_WITHOUT_OBJECTS', C_SCAN_DATE, l_findings);
  assert_equals(to_char(l_findings.count), '0', 'empty class produces no finding');
  fsm_monitor.scan(C_TEST_CLASS, null, l_findings);
  assert_equals(to_char(l_findings.count), '2', 'NULL scan date defaults to current database time');

  select fsm.get_escalation_state(l_fsm_id) into l_value from dual;
  assert_equals(l_value, 'ALERT', 'get_escalation_state reads persisted projection');
  rollback;
  select fsm_fms_id, fsm_monitor_status_date into l_value, l_date
    from fsm_objects where fsm_id = l_fsm_id;
  assert_equals(l_value, 'ALERT', 'autonomous scan survives caller rollback');

  cleanup;
exception when others then cleanup; raise;
end;
/

drop type fsm_monitor_test_type;
