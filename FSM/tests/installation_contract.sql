prompt Running installation contract tests

declare
  l_count binary_integer;
  procedure assert_equals(p_actual in number, p_expected in number, p_test in varchar2) as
  begin
    if p_actual = p_expected then
      dbms_output.put_line('PASS: ' || p_test);
    else
      raise_application_error(-20000, p_test || ': expected [' || p_expected || '], got [' || p_actual || ']');
    end if;
  end assert_equals;
begin
  select count(*) into l_count
    from user_objects
   where object_name in ('FSM', 'FSM_ADMIN', 'FSM_MONITOR', 'FSM_TYPE')
     and object_type in ('PACKAGE', 'TYPE');
  assert_equals(l_count, 4, 'public runtime objects are installed');

  select count(*) into l_count from parameter_v
   where par_id = 'AUTO_COMMIT' and par_pgr_id = 'FSM'
     and par_boolean_value is not null;
  assert_equals(l_count, 1, 'FSM commit policy is installed as a PIT boolean');

  select count(*) into l_count
    from user_tab_columns
   where table_name = 'FSM_OBJECTS'
     and column_name in ('FSM_FMS_ID', 'FSM_MONITOR_STATUS_DATE');
  assert_equals(l_count, 2, 'monitor projection columns are installed');

  select count(*) into l_count
    from fsm_monitor_status
   where fms_id in ('OK', 'WARN', 'ALERT')
     and fms_active = pit_util.C_TRUE;
  assert_equals(l_count, 3, 'global active monitor statuses are installed');

  select count(*) into l_count
    from (select fms_sort_seq from fsm_monitor_status
           where fms_id in ('OK', 'WARN', 'ALERT')
           group by fms_sort_seq having count(*) > 1);
  assert_equals(l_count, 0, 'monitor status ranks are unique');

  select count(*) into l_count
    from user_constraints
   where table_name = 'FSM_OBJECTS'
     and constraint_name = 'FK_FSM_FMS_ID'
     and status = 'ENABLED';
  assert_equals(l_count, 1, 'monitor status foreign key is enabled');

  select count(*) into l_count
    from user_objects
   where object_name in (
           'FSM', 'FSM_ADMIN', 'FSM_MONITOR', 'FSM_TYPE',
           'FSM_CLASSES_TV', 'FSM_SUB_CLASSES_TV', 'FSM_STATUS_GROUPS_TV', 'FSM_STATUS_SEVERITIES_TV', 'FSM_MONITOR_STATUS_TV', 'FSM_EVENTS_TV', 'FSM_STATUS_TV', 'FSM_TRANSITIONS_TV', 'FSM_OBJECTS_TV', 'FSM_LOG_TV',
           'FSM_CLASSES_V', 'FSM_SUB_CLASSES_V', 'FSM_STATUS_GROUPS_V',
           'FSM_STATUS_SEVERITIES_V', 'FSM_MONITOR_STATUS_V',
           'FSM_EVENTS_V', 'FSM_STATUS_V', 'FSM_TRANSITIONS_V',
           'FSM_OBJECTS_V', 'FSM_LOG_V', 'BL_FSM_ACTIVE_STATUS_EVENT',
           'BL_FSM_EDGES', 'BL_FSM_NEXT_COMMANDS')
     and status = 'INVALID';
  assert_equals(l_count, 0, 'installation contains no invalid objects');
end;
/
