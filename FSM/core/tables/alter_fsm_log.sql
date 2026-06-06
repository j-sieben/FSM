@&tools.check_has_column fsm_log fsl_fev_id "&ORA_NAME_TYPE."
comment on column fsm_log.fsl_fev_id is 'Event that caused the status log entry';

@&tools.check_has_column fsm_log fsl_prev_fst_id "&ORA_NAME_TYPE."
comment on column fsm_log.fsl_prev_fst_id is 'Previous state before the logged status was reached';

@&tools.check_has_column fsm_log fsl_transition_reason_msg_id "&ORA_NAME_TYPE."
comment on column fsm_log.fsl_transition_reason_msg_id is 'PIT message ID describing the static transition reason';

@&tools.check_has_column fsm_log fsl_reason_msg_id "&ORA_NAME_TYPE."
comment on column fsm_log.fsl_reason_msg_id is 'PIT message ID describing the runtime reason';

@&tools.check_has_column fsm_log fsl_reason_msg_args "msg_args_char"
comment on column fsm_log.fsl_reason_msg_args is 'Optional runtime reason message arguments';
