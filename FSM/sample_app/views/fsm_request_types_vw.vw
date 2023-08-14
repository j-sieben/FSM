create or replace view fsm_request_types_vw as
select rtp_id, pti_name rtp_name, pti_description rtp_description, rtp_active
  from fsm_request_types
  join pit_translatable_item_v
    on rtp_pti_id = pti_id
 where pti_pmg_name = 'REQ';
