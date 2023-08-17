create or replace view fsm_requests_vw as
select fsm_id req_id, fcl_id req_fcl_id, fst_id req_fst_id, fsm_fev_id req_fev_id, fsm_fev_list req_fev_list,
       fsm_retry_schedule req_retry_schedule, fsm_validity req_validity,
       req_rtp_id, req_rre_id, req_text
  from fsm_objects_v
  join fsm_requests
    on fsm_id = req_id;
    
comment on table fsm_requests_vw is 'Access View for a persisted Request';