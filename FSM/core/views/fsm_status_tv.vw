/**
  View: FSM_STATUS_TV
    Language-neutral, unfiltered technical read contract for <FSM_STATUS>.
    Explicit 1:1 projection; keys and stored payloads retain their table semantics.

  Dependencies:
    <FSM_STATUS> only; no translated lookups.
 */

create or replace view fsm_status_tv as
select fst_id,
       fst_fcl_id,
       fst_fsg_id,
       fst_msg_id,
       fst_pti_id,
       fst_retries_on_error,
       fst_retry_schedule,
       fst_retry_time,
       fst_warn_interval,
       fst_alert_interval,
       fst_escalation_basis,
       fst_icon_css,
       fst_name_css,
       fst_initial_status,
       fst_terminal_status,
       fst_active
  from fsm_status;

comment on table fsm_status_tv is 'Language-neutral technical read contract for FSM_STATUS; not internationalized; no translated lookups; all stored rows and columns';
comment on column fsm_status_tv.fst_id is 'primary key';
comment on column fsm_status_tv.fst_fcl_id is 'Primary key, reference to fsm_CLASS';
comment on column fsm_status_tv.fst_fsg_id is 'Grouping criterion';
comment on column fsm_status_tv.fst_msg_id is 'Name of the message to be used for logging, reference to MESSAGE';
comment on column fsm_status_tv.fst_pti_id is 'Translatable item, Reference to PIT_TRANSLATABLE_ITEM';
comment on column fsm_status_tv.fst_retries_on_error is 'How many retries should be made in case of error? Default: 0';
comment on column fsm_status_tv.fst_retry_schedule is 'Optional setting: If FST_RETRIES_ON_ERROR > 0: Which schedule should be used to make a retry';
comment on column fsm_status_tv.fst_retry_time is 'Optional setting: If FST_RETRIES_ON_ERROR > 0: How long to wait before retrying?';
comment on column fsm_status_tv.fst_warn_interval is 'Optional lower threshold for the expected duration in this status before escalation to WARN.';
comment on column fsm_status_tv.fst_alert_interval is 'Optional upper threshold for the expected duration in this status before escalation to ALERT.';
comment on column fsm_status_tv.fst_escalation_basis is 'Determines whether elapsed time is measured from the last status change (STATUS) or the last successful event/activity (EVENT).';
comment on column fsm_status_tv.fst_icon_css is 'Optional icon to control the display in reports';
comment on column fsm_status_tv.fst_name_css is 'Optional CSS class to control the display in reports';
comment on column fsm_status_tv.fst_initial_status is 'Flag indicating whether this status is the first status to enter when creating a new fsm object';
comment on column fsm_status_tv.fst_terminal_status is 'Flag indicating whether this status is a terminal/final status of the workflow';
comment on column fsm_status_tv.fst_active is 'Flag indicating whether the class is currently used';
