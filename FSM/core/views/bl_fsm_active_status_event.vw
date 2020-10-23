create or replace view bl_fsm_active_status_event as 
select fst_id, fev_id, ftr_fcl_id fcl_id,
       fst_name, fst_description, fst_msg_id,
       fev_name, fev_description, fev_command, fev_msg_id,
       ftr_required_role, ftr_raise_automatically, ftr_raise_on_status
  from fsm_transition ftr
  join fsm_status fst on ftr.ftr_fst_id = fst.fst_id and ftr.ftr_fcl_id = fst.fst_fcl_id
  join fsm_event fev on ftr.ftr_fev_id = fev.fev_id and ftr.ftr_fcl_id = fev.fev_fcl_id
 where ftr_active = 'Y'
   and fst_active = 'Y'
   and fev_active = 'Y';
