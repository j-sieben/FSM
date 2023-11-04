create or replace view bl_fsm_next_commands as
with params as (
       select /*+ no_merge */ pit_util.C_TRUE C_TRUE
         from dual)
select fsm_id, fev_id, fev_command_label, fev_description, ftr_required_role, fev_button_highlight, fev_button_icon, fev_confirm_message, C_TRUE
  from fsm_objects_v
  join fsm_events_v
    on instr(fsm_fev_list, fev_id) > 0
   and fsm_fcl_id = fev_fcl_id
  join fsm_transitions_v
    on fsm_fcl_id = ftr_fcl_id
   and fsm_fst_id = ftr_fst_id
   and fev_id = ftr_fev_id
  join params
    on fev_raised_by_user = C_TRUE
 where fev_id not in ('NIL');
 
comment on table bl_fsm_next_commands is 'BL view to prepare a list query with all possible next commands for a fiven FSM instance';