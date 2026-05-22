alter table fsm_transitions drop constraint pk_fsm_transitions;

alter table fsm_transitions add constraint pk_fsm_transitions primary key 
(ftr_fst_id, ftr_fev_id, ftr_fcl_id, ftr_fsc_id);
