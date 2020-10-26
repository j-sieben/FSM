create or replace view fsm_transitions_v as
select ftr_fst_id, ftr_fev_id, ftr_fcl_id, ftr_fst_list, 
       ftr_required_role, ftr_raise_automatically, ftr_raise_on_status, ftr_active
  from fsm_transitions;
 