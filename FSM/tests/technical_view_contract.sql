prompt Running language-neutral technical view contracts (FSM owner)

declare
  l_count number;
  l_base_count number;
  l_view_count number;
  l_base_xml clob;
  l_view_xml clob;
  l_language varchar2(100);
  l_sort varchar2(1000);
  l_columns varchar2(4000);
  procedure assert_zero(p_count number, p_test varchar2) as
  begin
    if p_count is null or p_count != 0 then
      raise_application_error(-20000, p_test || ': ' || p_count);
    end if;
  end;
  procedure restore_language as
  begin
    execute immediate 'alter session set nls_language = ''' || l_language || '''';
  end;
begin
  select value into l_language from nls_session_parameters where parameter = 'NLS_LANGUAGE';
  for obj in (
    select column_value base_name from table(sys.odcivarchar2list(
      'FSM_CLASSES', 'FSM_SUB_CLASSES', 'FSM_STATUS_GROUPS',
      'FSM_STATUS_SEVERITIES', 'FSM_MONITOR_STATUS', 'FSM_EVENTS',
      'FSM_STATUS', 'FSM_TRANSITIONS', 'FSM_OBJECTS', 'FSM_LOG')))
  loop
    select count(*) into l_count from user_objects
     where object_name = obj.base_name || '_TV' and object_type = 'VIEW' and status = 'VALID';
    assert_zero(1 - l_count, obj.base_name || ': valid technical view');

    -- Column order may differ on upgraded tables; names and SQL types must match.
    select count(*) into l_count
      from (
        select column_name, data_type, data_type_owner, data_length,
               data_precision, data_scale, char_used, char_length
          from user_tab_columns where table_name = obj.base_name
        minus
        select column_name, data_type, data_type_owner, data_length,
               data_precision, data_scale, char_used, char_length
          from user_tab_columns where table_name = obj.base_name || '_TV');
    assert_zero(l_count, obj.base_name || ': missing or changed columns');
    select count(*) into l_count
      from user_tab_columns where table_name = obj.base_name;
    select count(*) into l_base_count
      from user_tab_columns where table_name = obj.base_name || '_TV';
    assert_zero(l_count - l_base_count, obj.base_name || ': extra columns');

    select count(*) into l_count from user_dependencies d
     where d.name = obj.base_name || '_TV'
       and not (d.referenced_owner = user and d.referenced_name = obj.base_name and d.referenced_type = 'TABLE')
       -- Stored collection payloads may also register their SQL type dependency.
       and not (d.referenced_type = 'TYPE' and exists (
         select 1 from user_tab_columns c
          where c.table_name = obj.base_name || '_TV'
            and c.data_type_owner = d.referenced_owner
            and c.data_type = d.referenced_name));
    assert_zero(l_count, obj.base_name || ': external/enriched/language dependency');
    select count(*) into l_count from user_dependencies
     where name = obj.base_name || '_TV' and referenced_name = obj.base_name and referenced_type = 'TABLE';
    assert_zero(l_count - 1, obj.base_name || ': single base-table dependency');

    select listagg(cc.column_name, ',') within group (order by cc.position)
      into l_sort
      from user_constraints c join user_cons_columns cc on c.constraint_name = cc.constraint_name
     where c.table_name = obj.base_name and c.constraint_type = 'P';
    for lang in (select 'AMERICAN' name from dual union all select 'GERMAN' from dual) loop
      execute immediate 'alter session set nls_language = ''' || lang.name || '''';
      execute immediate 'select count(*) from ' || obj.base_name into l_base_count;
      execute immediate 'select count(*) from ' || obj.base_name || '_TV' into l_view_count;
      assert_zero(l_view_count - l_base_count, obj.base_name || ': row multiplicity');
      -- Equal names/order in the XML compare every value, including CLOBs and
      -- nested MSG_ARGS_CHAR payloads, sorted by the complete primary key.
      select listagg(column_name, ',') within group (order by column_id)
        into l_columns from user_tab_columns where table_name = obj.base_name || '_TV';
      l_base_xml := dbms_xmlgen.getxml('select ' || l_columns || ' from ' || obj.base_name || ' order by ' || l_sort);
      l_view_xml := dbms_xmlgen.getxml('select ' || l_columns || ' from ' || obj.base_name || '_TV order by ' || l_sort);
      assert_zero(dbms_lob.compare(l_base_xml, l_view_xml), obj.base_name || ': complete values in ' || lang.name);
      dbms_lob.freetemporary(l_base_xml);
      dbms_lob.freetemporary(l_view_xml);
    end loop;
    dbms_output.put_line('PASS: ' || obj.base_name || '_TV columns, dependencies, rows and values');
  end loop;
  restore_language;
exception
  when others then
    restore_language;
    raise;
end;
/
