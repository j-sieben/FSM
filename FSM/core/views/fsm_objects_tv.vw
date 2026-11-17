/**
  View: FSM_OBJECTS_TV
    Language-neutral, unfiltered technical read contract for <FSM_OBJECTS>.
    Explicit 1:1 projection; keys and stored payloads retain their table semantics.

  Dependencies:
    <FSM_OBJECTS> only; no translated lookups.
 */

create or replace view fsm_objects_tv as
select fsm_id,
       fsm_fcl_id,
       fsm_fsc_id,
       fsm_fst_id,
       fsm_fev_id,
       fsm_retry_schedule,
       fsm_validity,
       fsm_fev_list,
       fsm_last_change_date,
       fsm_status_change_date,
       fsm_fms_id,
       fsm_monitor_status_date
  from fsm_objects;

comment on table fsm_objects_tv is 'Language-neutral technical read contract for FSM_OBJECTS; not internationalized; no translated lookups; all stored rows and columns';
comment on column fsm_objects_tv.fsm_id is 'Technical key, generated from FSM_SEQ, primary key';
comment on column fsm_objects_tv.fsm_fcl_id is 'Document class, reference to FSM_CLASSES';
comment on column fsm_objects_tv.fsm_fsc_id is 'Document class, reference to FSM_SUB_CLASSES';
comment on column fsm_objects_tv.fsm_fst_id is 'Current document status, reference to FSM_STATUS';
comment on column fsm_objects_tv.fsm_fev_id is 'Optional event to retrigger due to an error, reference to FSM_EVENTS';
comment on column fsm_objects_tv.fsm_retry_schedule is 'Optional name of a schedule that plans when to retrigger FSM_FEV_ID';
comment on column fsm_objects_tv.fsm_validity is 'Current validity of fsm 0 = OK, 1 = Error, >1 = Error, [FSM_VALIDITY - 1] further attempts will follow';
comment on column fsm_objects_tv.fsm_fev_list is 'List of currently allowed next events';
comment on column fsm_objects_tv.fsm_last_change_date is 'Date of the last successful activity or event affecting the object.';
comment on column fsm_objects_tv.fsm_status_change_date is 'Date of the last actual status change of the object.';
comment on column fsm_objects_tv.fsm_fms_id is 'Last monitor status detected by FSM_MONITOR.';
comment on column fsm_objects_tv.fsm_monitor_status_date is 'Date on which the current monitor status was detected or became effective.';
