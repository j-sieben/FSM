create or replace view fsm_monitor_status_v as
select fms_id, pti_name fms_name, pti_display_name fms_display_name,
       pti_description fms_description, fms_sort_seq, fms_active
  from fsm_monitor_status
  join pit_translatable_item_v
    on fms_pti_id = pti_id
   and fms_pmg_name = pti_pmg_name;

comment on table fsm_monitor_status_v is 'Translatable lookup for global FSM monitor states';
comment on column fsm_monitor_status_v.fms_id is 'Technical monitor status identifier';
comment on column fsm_monitor_status_v.fms_name is 'Translated monitor status name';
comment on column fsm_monitor_status_v.fms_display_name is 'Translated display name';
comment on column fsm_monitor_status_v.fms_description is 'Translated monitor status description';
comment on column fsm_monitor_status_v.fms_sort_seq is 'Severity order; higher values take precedence';
comment on column fsm_monitor_status_v.fms_active is 'Flag indicating whether the monitor status is active';
