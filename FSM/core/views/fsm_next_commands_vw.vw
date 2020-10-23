create or replace force view fsm_next_commands_vw as 
with next_events as
       (select fsm_id, fev_id, fev_command, fev_description, ftr_required_role, fev_button_highlight, fev_button_icon, fev_confirm_message
          from fsm_object
          join fsm_event
            on instr(fsm_fev_list, fev_id) > 0
           and fsm_fcl_id = fev_fcl_id
          join fsm_transition
            on fsm_fcl_id = ftr_fcl_id
           and fsm_fst_id = ftr_fst_id
           and fev_id = ftr_fev_id
         where fev_raised_by_user = 'Y'
       )
select distinct fsm_id,
       null lvl,
       fev_command label,
       case
       when fev_confirm_message is not null then
         'javascript:apex.confirm('''|| fev_confirm_message || ''', ''' || fev_id || ''');'
       else
         'javascript:apex.submit('''|| fev_id || ''');'
       end target,
       case fev_button_highlight
       when 'Y' then 'YES' 
       else 'NO' end is_current,
       fev_button_icon image,
       null image_attrib,
       fev_description image_alt
  from next_events ev
 where ev.fev_id not in ('NIL');

