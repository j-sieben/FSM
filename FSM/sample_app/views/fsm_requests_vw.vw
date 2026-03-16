create or replace view fsm_requests_vw as
select fsm_id req_id, fsm_fcl_id req_fcl_id, fsm_fst_id req_fst_id, fsm_fev_id req_fev_id, fsm_fev_list req_fev_list,
       fsm_retry_schedule req_retry_schedule, fsm_validity req_validity,
       fsm_initial_status req_initial_status, fsm_terminal_status req_terminal_status,
       fsm_last_change_date req_last_change_date, fsm_status_change_date req_status_change_date,
       status_state req_status_state,
       req_rtp_id, req_rre_id, req_text
  from fsm_objects_v
  join fsm_requests
    on fsm_id = req_id;
    
comment on table fsm_requests_vw is 'Access View for a persisted Request';
