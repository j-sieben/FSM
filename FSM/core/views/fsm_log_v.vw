create or replace view fsm_log_v as
select fsl_id, fsl_fsm_id, fsl_user_name, fsl_session_id, fsl_log_date,
       fsl_msg_id, fsl_msg_args,
       fsl_severity, fss_name fsl_severity_name, fss_display_name fsl_severity_display_name, fss_icon fsl_severity_icon, fss_html fsl_severity_html, 
       fsl_fst_id, fst_name fsl_fst_name,
       fst_initial_status fsl_fst_initial_status,
       fst_terminal_status fsl_fst_terminal_status,
       fsg_id fsl_fsg_id, fsg_name fsl_fsg_name,
       fsl_fev_id, fsl_prev_fst_id, fsl_fev_list, fsl_fcl_id, fsl_fsc_id,
       fsl_transition_reason_msg_id, msg_args() fsl_transition_reason_msg_args,
       fsl_reason_msg_id, fsl_reason_msg_args
  from fsm_log
  join fsm_status_v 
    on fsl_fst_id = fst_id
   and fsl_fcl_id = fst_fcl_id
  join fsm_status_groups_v 
    on fst_fsg_id = fsg_id
   and fsl_fcl_id = fsg_fcl_id
  join fsm_status_severities_v
    on fsl_severity = fss_id;
