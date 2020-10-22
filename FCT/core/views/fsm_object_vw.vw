create or replace force view &TOOLKIT._object_vw as 
select fsm_id, fsm_fcl_id fcl_id, 
       fst_id, fst_name, fst_name_css, fst_icon_css, 
       fsg_id, fsg_name, fsg_name_css, fsg_icon_css,
       fsm_fev_id, fsm_fev_list, fsm_retry_schedule, 
       fsm_validity, fsm_last_change_date
  from fsm_object
  join fsm_status fst
    on fsm_fst_id = fst_id
   and fsm_fcl_id = fst_fcl_id
  join fsm_status_group fsg
    on fst_fsg_id = fsg_id;

