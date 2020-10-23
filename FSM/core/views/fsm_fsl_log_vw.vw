create or replace force view fsm_fsl_log_vw as 
select l.fsl_fsm_id, l.fsl_log_date, replace(l.fsl_msg_text, s.fst_id, s.fst_name) fsl_msg_text
  from fsm_log l
  join fsm_object o
    on l.fsl_fsm_id = o.fsm_id
  join fsm_status s
    on o.fsm_fst_id = s.fst_id
 where fsl_severity < 70
 order by fsl_id;

