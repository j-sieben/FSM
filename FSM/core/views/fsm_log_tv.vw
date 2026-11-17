/**
  View: FSM_LOG_TV
    Language-neutral, unfiltered technical read contract for <FSM_LOG>.
    Explicit 1:1 projection; keys and stored payloads retain their table semantics.

  Dependencies:
    <FSM_LOG> only; no translated lookups.
 */

create or replace view fsm_log_tv as
select fsl_id,
       fsl_fsm_id,
       fsl_user_name,
       fsl_session_id,
       fsl_log_date,
       fsl_msg_text,
       fsl_severity,
       fsl_fst_id,
       fsl_fev_list,
       fsl_fcl_id,
       fsl_fsc_id,
       fsl_msg_id,
       fsl_msg_args,
       fsl_fev_id,
       fsl_prev_fst_id,
       fsl_transition_reason_msg_id,
       fsl_reason_msg_id,
       fsl_reason_msg_args
  from fsm_log;

comment on table fsm_log_tv is 'Language-neutral technical read contract for FSM_LOG; not internationalized; no translated lookups; all stored rows and columns';
comment on column fsm_log_tv.fsl_id is 'Primary key, populated by PIT';
comment on column fsm_log_tv.fsl_fsm_id is 'ID of the referenced FSM object, Reference to the FSM_OBJECTS';
comment on column fsm_log_tv.fsl_user_name is 'Username that created this log entry';
comment on column fsm_log_tv.fsl_session_id is 'Session ID of the session that created this entry';
comment on column fsm_log_tv.fsl_log_date is 'Timestamp of the log entry';
comment on column fsm_log_tv.fsl_msg_text is 'Generated message text';
comment on column fsm_log_tv.fsl_severity is 'Severity of the log entry, fi Milestone etc.';
comment on column fsm_log_tv.fsl_fst_id is 'Actual state the FSM object is in';
comment on column fsm_log_tv.fsl_fev_id is 'Event that caused the status log entry';
comment on column fsm_log_tv.fsl_prev_fst_id is 'Previous state before the logged status was reached';
comment on column fsm_log_tv.fsl_fev_list is 'List of allowed events that can be raised on the FSM object';
comment on column fsm_log_tv.fsl_fcl_id is 'Type of the FSM object, reference to FSM_CLASSES';
comment on column fsm_log_tv.fsl_fsc_id is 'Subtype of the FSM object, reference to FSM_SUB_CLASSES';
comment on column fsm_log_tv.fsl_msg_id is 'Name of the PIT message, used to display the log in a different language';
comment on column fsm_log_tv.fsl_msg_args is 'Optional message arguments';
comment on column fsm_log_tv.fsl_transition_reason_msg_id is 'PIT message ID describing the static transition reason';
comment on column fsm_log_tv.fsl_reason_msg_id is 'PIT message ID describing the runtime reason';
comment on column fsm_log_tv.fsl_reason_msg_args is 'Optional runtime reason message arguments';
