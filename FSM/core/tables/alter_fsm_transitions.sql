alter table fsm_transitions drop constraint pk_fsm_transitions;

alter table fsm_transitions add constraint pk_fsm_transitions primary key 
(ftr_fst_id, ftr_fev_id, ftr_fcl_id, ftr_fsc_id);

@&tools.check_has_column fsm_transitions ftr_reason_msg_id "&ORA_NAME_TYPE."
comment on column fsm_transitions.ftr_reason_msg_id is 'Optional PIT message ID describing the static reason for this transition';
