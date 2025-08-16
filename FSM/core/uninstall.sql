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
                 'FSM_TYPE', -- Typen
                 'FSM_ADMIN', 'FSM', 'FSM_FST', 'FSM_FEV', -- Packages
                 'BL_FSM_ACTIVE_STATUS_EVENT', 'BL_FSM_HIEARCHY', 'BL_FSM_NEXT_COMMANDS', 
                 'FSM_LOG_V', 'FSM_FSL_LOG_V', 'BL_FSM_HIERARCHY', 'BL_FSM_NEXT_COMMANDS', 'FSM_OBJECTS_V', 
                 'FSM_CLASSES_V', 'FSM_SUB_CLASSES_V', 'FSM_EVENTS_V', 'FSM_FCL_EVENTS_V', 'FSM_STATUS_GROUPS_V', 'FSM_STATUS_SEVERITIES_V', 'FSM_STATUS_V', 'FSM_TRANSITIONS_V', -- Views
                 'FSM_CLASSES', 'FSM_SUB_CLASSES', 'FSM_EVENTS', 'FSM_LOG', 'FSM_OBJECTS', 'FSM_STATUS', 'FSM_STATUS_GROUPS',
                 'FSM_STATUS_SEVERITIES', 'FSM_TRANSITIONS', -- Tabellen
                 '',  -- Synonyme
                 'FSM_SEQ', 'FSM_LOG_SEQ' -- Sequenzen
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
                        when 'TABLE' then ' cascade constraints' 
                        end;
      dbms_output.put_line('. - ' || initcap(obj.type) || ' ' || obj.name || ' deleted.');
    
    exception
      when object_does_not_exist or table_does_not_exist or sequence_does_not_exist or synonym_does_not_exist then
        dbms_output.put_line('. - ' || obj.type || ' ' || obj.name || ' does not exist.');
      when others then
        raise;
    end;
  end loop;
  
  pit_admin.delete_message_group('FSM', true);
  
end;
/