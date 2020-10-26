create or replace force view fsm_objects_v as 
select fsm_id, fsm_fcl_id fcl_id, 
       fst_id, fst_name, fst_name_css, fst_icon_css, 
       fsg_id, fsg_name, fsg_name_css, fsg_icon_css,
       fsm_fev_id, fsm_fev_list, fsm_retry_schedule, 
       fsm_validity, fsm_last_change_date
  from fsm_objects
  join fsm_status_v
    on fsm_fst_id = fst_id
   and fsm_fcl_id = fst_fcl_id
  join fsm_status_groups_v
    on fst_fsg_id = fsg_id;

