set define on
set verify off
set feedback on
set serveroutput on size unlimited
whenever oserror exit failure rollback
whenever sqlerror exit failure rollback

prompt ============================================================
prompt FSM test suite
prompt ============================================================

@@installation_contract.sql
@@monitor_scan.sql
@@runtime_contract.sql
@@log_reason_overloads.sql
@@admin_contract.sql

declare
  l_invalid_count binary_integer;
begin
  select count(*) into l_invalid_count
    from user_objects
   where object_name in (
           'FSM', 'FSM_ADMIN', 'FSM_MONITOR', 'FSM_TYPE',
           'FSM_CLASSES_V', 'FSM_SUB_CLASSES_V', 'FSM_STATUS_GROUPS_V',
           'FSM_STATUS_SEVERITIES_V', 'FSM_MONITOR_STATUS_V',
           'FSM_EVENTS_V', 'FSM_STATUS_V', 'FSM_TRANSITIONS_V',
           'FSM_OBJECTS_V', 'FSM_LOG_V', 'BL_FSM_ACTIVE_STATUS_EVENT',
           'BL_FSM_EDGES', 'BL_FSM_NEXT_COMMANDS')
     and status = 'INVALID';
  if l_invalid_count > 0 then
    raise_application_error(-20000, 'Test suite left ' || l_invalid_count || ' invalid object(s)');
  end if;
  dbms_output.put_line('PASS: no invalid objects after the complete suite');
end;
/

prompt ============================================================
prompt FSM test suite passed
prompt ============================================================
exit success
