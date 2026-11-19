/**
  View: FSM_MONITOR_STATUS_TV
    Language-neutral, unfiltered technical read contract for <FSM_MONITOR_STATUS>.
    Explicit 1:1 projection; keys and stored payloads retain their table semantics.

  Dependencies:
    <FSM_MONITOR_STATUS> only; no translated lookups.
 */

create or replace view fsm_monitor_status_tv as
select fms_id,
       fms_pti_id,
       fms_pmg_name,
       fms_sort_seq,
       fms_active
  from fsm_monitor_status;

comment on table fsm_monitor_status_tv is 'Language-neutral technical read contract for FSM_MONITOR_STATUS; not internationalized; no translated lookups; all stored rows and columns';
comment on column fsm_monitor_status_tv.fms_id is 'Technical monitor status identifier';
comment on column fsm_monitor_status_tv.fms_pti_id is 'Translatable item in the FSM message group';
comment on column fsm_monitor_status_tv.fms_pmg_name is 'PIT message group, fixed to FSM';
comment on column fsm_monitor_status_tv.fms_sort_seq is 'Severity order';
comment on column fsm_monitor_status_tv.fms_active is 'Flag indicating whether the monitor status is active';
