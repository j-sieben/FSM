create or replace view bl_fsm_active_status_event as
with params as (
       select /*+ no_merge */ pit_util.C_TRUE C_TRUE
         from dual)
select fst_id, fev_id, ftr_fcl_id fcl_id,
       fst_name, fst_description, fst_msg_id,
       fev_name, fev_description, fev_command_label, fev_msg_id,
       ftr_required_role, ftr_raise_automatically, ftr_raise_on_status
  from fsm_transitions_v
  join fsm_status_v
    on ftr_fst_id = fst_id
   and ftr_fcl_id = fst_fcl_id
  join fsm_events_v
    on ftr_fev_id = fev_id
   and ftr_fcl_id = fev_fcl_id
  join params
    on ftr_active = C_TRUE
   and fst_active = C_TRUE
   and fev_active = C_TRUE;
   
comment on table bl_fsm_active_status_event is 'BL view to calculate the possible next events for a given FSM instance';