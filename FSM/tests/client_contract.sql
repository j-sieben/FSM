prompt Running FSM client-schema contract tests

define FSM_OWNER = '&1.'

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
    from user_synonyms
   where synonym_name in ('FSM', 'FSM_ADMIN', 'FSM_MONITOR', 'FSM_TYPE')
     and table_owner = upper('&FSM_OWNER.');
  assert_equals(l_count, 4, 'client exposes the public runtime synonyms');

  select count(*) into l_count
    from all_tab_privs
   where owner = upper('&FSM_OWNER.')
     and grantee = user
     and table_name in ('FSM', 'FSM_ADMIN', 'FSM_MONITOR', 'FSM_TYPE')
     and privilege = 'EXECUTE';
  assert_equals(l_count, 4, 'client has execute grants on public runtime objects');

  select count(*) into l_count
    from user_synonyms
   where synonym_name in ('FSM_OBJECTS_V', 'FSM_MONITOR_STATUS_V')
     and table_owner = upper('&FSM_OWNER.');
  assert_equals(l_count, 2, 'client exposes monitor read models');
end;
/

exit success
