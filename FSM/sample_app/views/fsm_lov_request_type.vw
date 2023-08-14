create or replace view fsm_lov_request_type as
select rtp_name d, rtp_id r, rtp_active is_active
  from fsm_request_types_vw;
  
comment on table fsm_lov_request_type is 'LOV-View for the Request types of the sample application';