create or replace view fsm_ui_edit_request as
select req_id, req_rtp_id, req_rre_id, req_text
  from fsm_requests_vw;
  
comment on table fsm_ui_edit_request is 'UI-View for page EDIT_REQUEST';