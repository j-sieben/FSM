create or replace view fsm_log_v as
select fsl_id, fsl_fsm_id, fsl_user_name, fsl_session_id, fsl_log_date,
       fsl_msg_id, pit.get_message_text(fsl_msg_id, fsl_msg_args) fsl_msg_text,
       fsl_severity, fsl_fst_id, fsl_fev_list, fsl_fcl_id
  from fsm_log;