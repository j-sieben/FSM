/**
  View: FSM_TRANSITIONS_TV
    Language-neutral, unfiltered technical read contract for <FSM_TRANSITIONS>.
    Explicit 1:1 projection; keys and stored payloads retain their table semantics.

  Dependencies:
    <FSM_TRANSITIONS> only; no translated lookups.
 */

create or replace view fsm_transitions_tv as
select ftr_fst_id,
       ftr_fev_id,
       ftr_fcl_id,
       ftr_fsc_id,
       ftr_fst_list,
       ftr_active,
       ftr_required_role,
       ftr_raise_automatically,
       ftr_raise_on_status,
       ftr_reason_msg_id
  from fsm_transitions;

comment on table fsm_transitions_tv is 'Language-neutral technical read contract for FSM_TRANSITIONS; not internationalized; no translated lookups; all stored rows and columns';
comment on column fsm_transitions_tv.ftr_fst_id is 'Primary key, reference to FSM_STATUS';
comment on column fsm_transitions_tv.ftr_fev_id is 'Primary key, reference to FSM_EVENTS';
comment on column fsm_transitions_tv.ftr_fcl_id is 'Primary key, Reference to FSM_CLASSES';
comment on column fsm_transitions_tv.ftr_fsc_id is 'Primary key, Reference to FSM_SUB_CLASSES, defaults to MASTER';
comment on column fsm_transitions_tv.ftr_fst_list is 'List of possible result states, :-separated list of FSM_STATUS.FST_ID.';
comment on column fsm_transitions_tv.ftr_active is 'Flag indicating whether an assignment should be used or not';
comment on column fsm_transitions_tv.ftr_required_role is 'Optional role restriction for an event, may only be thrown if user has role permission';
comment on column fsm_transitions_tv.ftr_raise_automatically is 'Flag indicating whether the event is automatically triggered immediately after a status is reached';
comment on column fsm_transitions_tv.ftr_raise_on_status is 'Defines a result state that triggers the following event. Allowed values: 0 = normal processing, 1 = event in case of error';
comment on column fsm_transitions_tv.ftr_reason_msg_id is 'Optional PIT message ID describing the static reason for this transition';
