declare
  object_does_not_exist exception;
  pragma exception_init(object_does_not_exist, -4043);
  table_does_not_exist exception;
  pragma exception_init(table_does_not_exist, -942);
  sequence_does_not_exist exception;
  pragma exception_init(sequence_does_not_exist, -2282);
  synonym_does_not_exist exception;
  pragma exception_init(synonym_does_not_exist, -1434);
  cursor delete_object_cur is
          select object_name name, object_type type
            from all_objects
           where object_name in (
                 'FSM_REQ_TYPE', -- Typen
                 'FSM_REQ_PKG', -- Packages
                 'FSM_REQ_OBJECT_VW', -- Views
                 'FSM_REQ_OBJECT', 'FSM_REQ_TYPES', 'FSM_REQ_REQUESTOR', 'DEMO_USER',  -- Tabellen
                 '',  -- Synonyme
                 '' -- Sequenzen
                 )
             and object_type not like '%BODY'
             and owner = upper('&INSTALL_USER.')
           order by object_type, object_name;
begin
  for obj in delete_object_cur loop
    begin
      execute immediate 'drop ' || obj.type || ' ' || obj.name ||
                        case obj.type 
                        when 'TYPE' then ' force' 
                        when 'TABLE' then ' cascade constraints purge' 
                        end;
     dbms_output.put_line('&s1.' || initcap(obj.type) || ' ' || obj.name || ' deleted.');
    
    exception
      when object_does_not_exist or table_does_not_exist or sequence_does_not_exist or synonym_does_not_exist then
        dbms_output.put_line('&s1.' || obj.type || ' ' || obj.name || ' does not exist.');
      when others then
        raise;
    end;
  end loop;
/*  
  delete from fsm_transition
   where ftr_fcl_id = '&FSM_CLASS.';
  dbms_output.put_line('&s1.' || sql%ROWCOUNT || ' transitions deleted.');
   
  delete from fsm_status
   where fst_fcl_id = '&FSM_CLASS.';
  dbms_output.put_line('&s1.' || sql%ROWCOUNT || ' status deleted.');
   
  delete from fsm_event
   where fev_fcl_id = '&FSM_CLASS.';
  dbms_output.put_line('&s1.' || sql%ROWCOUNT || ' events deleted.');
  
  delete from pit_message
   where pms_name like ('FSM_REQ%');
  dbms_output.put_line('&s1.' || sql%ROWCOUNT || ' PIT messages deleted.');
   
  delete from parameter_tab
   where par_pgr_id = 'FSM'
     and par_id in ('');
  dbms_output.put_line('&s1.' || sql%ROWCOUNT || ' parameters deleted.');
   
  commit;
  */
  fsm_admin_pkg.create_event_package;
  fsm_admin_pkg.create_status_package;
end;
/