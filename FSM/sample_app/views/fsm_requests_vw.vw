create or replace view fsm_requests_vw as
select fsm_id, fcl_id fsm_fcl_id, fst_id fsm_fst_id, fsm_fev_id, fsm_fev_list,
       fsm_retry_schedule, fsm_validity,
       req_rtp_id, req_rre_id, req_text
  from fsm_objects_v
  join fsm_requests
    on fsm_id = req_id;

select *
  from fsm_objects_v;