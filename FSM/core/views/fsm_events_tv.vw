/**
  View: FSM_EVENTS_TV
    Language-neutral, unfiltered technical read contract for <FSM_EVENTS>.
    Explicit 1:1 projection; keys and stored payloads retain their table semantics.

  Dependencies:
    <FSM_EVENTS> only; no translated lookups.
 */

create or replace view fsm_events_tv as
select fev_id,
       fev_fcl_id,
       fev_msg_id,
       fev_pti_id,
       fev_raised_by_user,
       fev_button_highlight,
       fev_confirm_message,
       fev_button_icon,
       fev_active
  from fsm_events;

comment on table fsm_events_tv is 'Language-neutral technical read contract for FSM_EVENTS; not internationalized; no translated lookups; all stored rows and columns';
comment on column fsm_events_tv.fev_id is 'Primary key';
comment on column fsm_events_tv.fev_fcl_id is 'Primary key, reference to FSM_CLASSES';
comment on column fsm_events_tv.fev_msg_id is 'Name of a message to be used for logging, reference to PIT_MESSAGE';
comment on column fsm_events_tv.fev_pti_id is 'Translatable item, reference to PIT_TRANSLATABLE_ITEM';
comment on column fsm_events_tv.fev_raised_by_user is 'Flag to indicate whether command is raisable by user (in contrast to events which are raised by jobs only).';
comment on column fsm_events_tv.fev_button_highlight is 'Flag to indicate whether command button shall be highlighted.';
comment on column fsm_events_tv.fev_confirm_message is 'Optional message that is shown before action takes place.';
comment on column fsm_events_tv.fev_button_icon is 'Optional css class resp. url to an icon.';
comment on column fsm_events_tv.fev_active is 'Flag to indicate whether status is in use actually.';
