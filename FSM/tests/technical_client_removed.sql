set define on
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

define FSM_OWNER = '&1.'

declare
  l_count number;
begin
  for obj in (select column_value name from table(sys.odcivarchar2list(
    'FSM_CLASSES_TV', 'FSM_SUB_CLASSES_TV', 'FSM_STATUS_GROUPS_TV',
    'FSM_STATUS_SEVERITIES_TV', 'FSM_MONITOR_STATUS_TV', 'FSM_EVENTS_TV',
    'FSM_STATUS_TV', 'FSM_TRANSITIONS_TV', 'FSM_OBJECTS_TV', 'FSM_LOG_TV')))
  loop
    select count(*) into l_count from user_synonyms where synonym_name = obj.name;
    if l_count != 0 then
      raise_application_error(-20000, 'Technical synonym remains: ' || obj.name);
    end if;
    select count(*) into l_count from all_tab_privs
     where table_schema = upper('&FSM_OWNER.') and grantee = user
       and table_name = obj.name;
    if l_count != 0 then
      raise_application_error(-20000, 'Technical grant remains: ' || obj.name);
    end if;
  end loop;
  dbms_output.put_line('PASS: all technical client grants and synonyms removed');
end;
/
exit success
