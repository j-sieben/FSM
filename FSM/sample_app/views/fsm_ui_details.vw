create or replace view fsm_ui_details as
with session_state as(
       select /*+ no_merge */
              utl_apex.get_number('req_id') req_id,
              coalesce(utl_apex.get_number('fsl_severity'), 0) req_severity
         from dual)
select fsl_id, fsl_fsm_id, fsl_log_date, fsl_msg_text, fss_name fsl_severity, fsl_user_name
  from fsm_log_v
  join session_state
    on fsl_fsm_id = req_id
  join fsm_status_severities_v
    on fsl_severity = fss_id
   and fss_fcl_id in ('REQ', 'FSM')
 where fsl_severity <= req_severity
 order by fsl_id desc;
 
 comment on table fsm_ui_details is 'UI view for page DETAILS';