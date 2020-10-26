create or replace force view bl_fsm_active_status_event as 
select fst_id, fev_id, ftr_fcl_id fcl_id,
       fst_name, fst_description, fst_msg_id,
       fev_name, fev_description, fev_command_label, fev_msg_id,
       ftr_required_role, ftr_raise_automatically, ftr_raise_on_status
  from fsm_transitions
  join fsm_status_v 
    on ftr_fst_id = fst_id 
   and ftr_fcl_id = fst_fcl_id
  join fsm_events_v
    on ftr_fev_id = fev_id 
   and ftr_fcl_id = fev_fcl_id
 where ftr_active = &C_TRUE.
   and fst_active = &C_TRUE.
   and fev_active = &C_TRUE.;
