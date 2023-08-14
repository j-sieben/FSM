create or replace view fsm_events_v as
select fev_id, fev_fcl_id, fev_msg_id, pti_name fev_name, pti_description fev_description,
       fev_raised_by_user, pti_display_name fev_command_label,
       fev_button_highlight, fev_confirm_message, fev_button_icon, fev_active
  from fsm_events
  join pit_translatable_item_v
    on fev_pti_id = pti_id
   and fev_fcl_id = pti_pmg_name;
 
comment on table fsm_events_v  is 'Table to store fsm status definitions per class type';
comment on column fsm_events_v.fev_id is 'Primary key';
comment on column fsm_events_v.fev_fcl_id is 'Primary key, reference to FSM_CLASSES';
comment on column fsm_events_v.fev_msg_id is 'Name of a message to be used for logging, reference to PIT_MESSAGE';
comment on column fsm_events_v.fev_name is 'Descriptive name for LOV';
comment on column fsm_events_v.fev_description is 'Optional description';
comment on column fsm_events_v.fev_raised_by_user is 'Flag to indicate whether command is raisable by user (in contrast to events which are raised by jobs only).';
comment on column fsm_events_v.fev_command_label is 'Label for control item (fi button)';
comment on column fsm_events_v.fev_button_highlight is 'Flag to indicate whether command button shall be highlighted.';
comment on column fsm_events_v.fev_confirm_message is 'Optional message that is shown before action takes place.';
comment on column fsm_events_v.fev_button_icon is 'Optional css class resp. url to an icon.';
comment on column fsm_events_v.fev_active is 'Flag to indicate whether status is in use actually.';