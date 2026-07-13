create or replace view fsm_ui_next_commands as
select distinct req_id,
       fsm_id,
       null lvl, 
       fev_command_label label, 
       case when fev_confirm_message is not null then
         'javascript:apex.confirm('''|| fev_confirm_message || ''', ''' || fev_id || ''');'
       else
         'javascript:apex.submit('''|| fev_id || ''');'
       end target,
       case fev_button_highlight
       when C_TRUE then 'YES' 
       else 'NO' end  is_current, 
       fev_button_icon image, 
       null image_attrib, 
       to_char(fev_description) image_alt
  from bl_fsm_next_commands
  join fsm_requests_vw
    on req_fsm_id = fsm_id;
    
comment on table fsm_ui_next_commands is 'LIST-query for all applicable next commands. Can be filtered by business REQ_ID or technical FSM_ID.';
