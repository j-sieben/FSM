create or replace force view bl_fsm_next_commands as 
with params as (
       select /*+ no_merge */ pit_util.C_TRUE C_TRUE
         from dual),
     next_events as
       (select fsm_id, fev_id, fev_command_label, fev_description, ftr_required_role, fev_button_highlight, fev_button_icon, fev_confirm_message, C_TRUE
          from fsm_objects_v
          join fsm_events_v
            on instr(fsm_fev_list, fev_id) > 0
           and fcl_id = fev_fcl_id
          join fsm_transitions_v
            on fcl_id = ftr_fcl_id
           and fst_id = ftr_fst_id
           and fev_id = ftr_fev_id
          join params
            on fev_raised_by_user = C_TRUE
       )
select distinct fsm_id,
       null lvl,
       fev_command_label label,
       case
       when fev_confirm_message is not null then
         'javascript:apex.confirm('''|| fev_confirm_message || ''', ''' || fev_id || ''');'
       else
         'javascript:apex.submit('''|| fev_id || ''');'
       end target,
       case fev_button_highlight
       when C_TRUE then 'YES' 
       else 'NO' end is_current,
       fev_button_icon image,
       null image_attrib,
       to_char(fev_description) image_alt
  from next_events ev
 where ev.fev_id not in ('NIL');

