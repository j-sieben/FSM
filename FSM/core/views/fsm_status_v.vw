create or replace view fsm_status_v as
select fst_id, fst_fcl_id, fst_fsg_id, fst_msg_id, pti_name fst_name, pti_description fst_description,
       fst_retries_on_error, fst_retry_schedule, fst_retry_time, fst_icon_css, fst_name_css, fst_active
  from fsm_status
  join pit_translatable_item_v
    on fst_pti_id = pti_id
   and fst_fcl_id = pti_pmg_name;