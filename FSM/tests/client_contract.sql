set define on
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

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
   where table_schema = upper('&FSM_OWNER.')
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

declare
  l_count number;
begin
  for obj in (select column_value name from table(sys.odcivarchar2list(
    'FSM_CLASSES_TV', 'FSM_SUB_CLASSES_TV', 'FSM_STATUS_GROUPS_TV', 'FSM_STATUS_SEVERITIES_TV', 'FSM_MONITOR_STATUS_TV', 'FSM_EVENTS_TV', 'FSM_STATUS_TV', 'FSM_TRANSITIONS_TV', 'FSM_OBJECTS_TV', 'FSM_LOG_TV')))
  loop
    select count(*) into l_count from user_synonyms
     where synonym_name = obj.name and table_name = obj.name
       and table_owner = upper('&FSM_OWNER.');
    if l_count != 1 then
      raise_application_error(-20000, 'Missing technical synonym: ' || obj.name);
    end if;
    select count(*) into l_count from all_tab_privs
     where table_schema = upper('&FSM_OWNER.') and grantee = user
       and table_name = obj.name and privilege = 'READ' and grantable = 'YES';
    if l_count != 1 then
      raise_application_error(-20000, 'Missing delegable READ grant: ' || obj.name);
    end if;
    execute immediate 'select count(*) from ' || obj.name into l_count;
    dbms_output.put_line('PASS: client grant, synonym and query ' || obj.name);
  end loop;
end;
/

exit success
