create or replace force view fsm_fsl_log_v as 
select fsl_fsm_id, fsl_log_date, replace(fsl_msg_text, fst_id, fst_name) fsl_msg_text
  from fsm_log
  join fsm_objects_v o
    on fsl_fsm_id = fsm_id
  join fsm_status_v
    on fsm_fst_id = fst_id
 where fsl_severity < 70
 order by fsl_id;

