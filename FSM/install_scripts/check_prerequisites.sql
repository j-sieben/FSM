declare
  l_privilege_missing boolean := false;
  
  cursor sys_priv_cur is
    select column_value privilege
      from table(char_table('CREATE VIEW', 'CREATE PROCEDURE', 'CREATE TABLE'))
    minus
    select privilege
      from user_sys_privs;
  
  cursor obj_priv_cur is
    (select 'EXECUTE' privilege, 'PACKAGE' type, 'DBMS_LOCK' name
      from dual)
    minus
    select privilege, type, table_name
      from user_tab_privs;
      
  cursor pkg_cur is
    (select 'PIT' object_name, 'PACKAGE' object_type
      from dual)
    minus
    select object_name, object_type
      from all_objects
     where object_type in ('PACKAGE');
begin
  for s in sys_priv_cur loop
    l_privilege_missing := true;
    dbms_output.put_line('- &INSTALL_USER. needs system privilege ' || s.privilege);
  end loop;
  
  for o in obj_priv_cur loop
    l_privilege_missing := true;
    dbms_output.put_line('- &INSTALL_USER. needs ' || lower(o.privilege) || ' privilege on ' || lower(o.type) || ' ' || o.name);
  end loop;
  
  for p in pkg_cur loop
    l_privilege_missing := true;
    dbms_output.put_line('- ' || p.object_name || ' must be installed in order to use FSM. Please install this first.');
  end loop;

  if not l_privilege_missing then
    dbms_output.put_line('- checked.');
  else
    raise_application_error(-20000, 'Prerequisites are not met, cannot install FSM');
  end if;
end;
/