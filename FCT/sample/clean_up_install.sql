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
                 '&TOOLKIT._REQ_TYPE', -- Typen
                 '&TOOLKIT._REQ_PKG', -- Packages
                 '&TOOLKIT._REQ_OBJECT_VW', -- Views
                 '&TOOLKIT._REQ_OBJECT', '&TOOLKIT._REQ_TYPES', '&TOOLKIT._REQ_REQUESTOR', 'DEMO_USER',  -- Tabellen
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
  
 /* delete from message
   where message_name in ('');*/
   
   
  delete from parameter_tab
   where parameter_group_id = '&TOOLKIT.'
     and parameter_id in ('');
   
  delete from &TOOLKIT._transition
   where ftr_fcl_id = '&FSM_CLASS.';
   
  delete from &TOOLKIT._status
   where fst_fcl_id = '&FSM_CLASS.';
   
  delete from &TOOLKIT._event
   where fev_fcl_id = '&FSM_CLASS.';
  
  &TOOLKIT._admin_pkg.create_event_package;
  &TOOLKIT._admin_pkg.create_status_package;
  
  commit;
end;
/