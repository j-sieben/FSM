create or replace force view fsm_objects_v as
with constants as (
  select 'OK' c_ok,
         'WARN' c_warn,
         'ALERT' c_alert,
         'EVENT' c_event
    from dual
)
select fsm_id, fsm_fcl_id, fsm_fsc_id,
       fst_id fsm_fst_id, fst_name fsm_fst_name, fst_name_css fsm_fst_name_css, fst_icon_css fsm_fst_icon_css, 
       fsg_id fsm_fsg_id, fsg_name fsm_fsg_name, fsg_name_css fsm_fsg_name_css, fsg_icon_css fsm_fsg_icon_css,
       fst_initial_status fsm_initial_status, fst_terminal_status fsm_terminal_status,
       fsm_fev_id, fsm_fev_list, fsm_retry_schedule, fsm_validity,
       fsm_last_change_date, fsm_status_change_date,
       case
         when fst_warn_interval is null or fst_alert_interval is null then c_ok
         when sysdate >= (case fst_escalation_basis
                            when c_event then fsm_last_change_date
                            else coalesce(fsm_status_change_date, fsm_last_change_date)
                          end + fst_alert_interval) then c_alert
         when sysdate >= (case fst_escalation_basis
                            when c_event then fsm_last_change_date
                            else coalesce(fsm_status_change_date, fsm_last_change_date)
                          end + fst_warn_interval) then c_warn
         else c_ok
       end fsm_status_state
  from fsm_objects
 cross join constants
  join fsm_classes_v
    on fsm_fcl_id = fcl_id
  join fsm_status_v
    on fsm_fst_id = fst_id
   and fsm_fcl_id = fst_fcl_id
  left join fsm_status_groups_v
    on fst_fsg_id = fsg_id
   and fst_fcl_id = fsg_fcl_id;

comment on table fsm_objects_v is 'Access view for FSM_OBJECTS.';
