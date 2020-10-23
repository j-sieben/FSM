create or replace view fsm_req_object_vw as
select fsm_id, fsm_fcl_id, fsm_fst_id, fsm_fev_id, fsm_fev_list,
       fsm_retry_schedule, fsm_validity,
       req_rtp_id, req_rre_id, req_text
  from fsm_object o
  join fsm_req_object r
    on o.fsm_id = r.req_id;
