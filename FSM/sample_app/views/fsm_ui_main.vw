create or replace view fsm_ui_main as
select req_id, fst_name, rre_name, rtp_name, req_text
  from fsm_requests_vw
  join fsm_status_v
    on req_fst_id = fst_id
  join fsm_requestors_vw
    on req_rre_id = rre_id
  join fsm_request_types_vw
    on req_rtp_id = rtp_id;
  
comment on table fsm_ui_main is 'UI view for page MAIN';