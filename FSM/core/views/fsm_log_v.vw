create or replace view fsm_log_v as
select fsl_id, fsl_fsm_id, fsl_user_name, fsl_session_id, fsl_log_date,
       fsl_msg_id, pit.get_message_text(fsl_msg_id, fsl_msg_args) fsl_msg_text,
       fsl_severity, fsl_fst_id, fst_name fsl_fst_name, fsg_id fsl_fsg_id, fsg_name fsl_fsg_name, fsl_fev_list, fsl_fcl_id, fsl_fsc_id
  from fsm_log
  join fsm_status_v 
    on fsl_fst_id = fst_id
   and fsl_fcl_id = fst_fcl_id
  join fsm_status_groups_v 
    on fst_fsg_id = fsg_id
   and fsl_fcl_id = fsg_fcl_id;