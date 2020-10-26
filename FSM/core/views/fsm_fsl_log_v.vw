create or replace force view fsm_fsl_log_v as 
select fsl_fsm_id, fsl_log_date, replace(fsl_msg_text, s.fst_id, s.fst_name) fsl_msg_text
  from fsm_log
  join fsm_objects_v o
    on fsl_fsm_id = o.fsm_id
  join fsm_status_v s
    on o.fst_id = s.fst_id
 where fsl_severity < 70
 order by fsl_id;

