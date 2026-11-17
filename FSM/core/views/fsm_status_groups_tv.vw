/**
  View: FSM_STATUS_GROUPS_TV
    Language-neutral, unfiltered technical read contract for <FSM_STATUS_GROUPS>.
    Explicit 1:1 projection; keys and stored payloads retain their table semantics.

  Dependencies:
    <FSM_STATUS_GROUPS> only; no translated lookups.
 */

create or replace view fsm_status_groups_tv as
select fsg_id,
       fsg_fcl_id,
       fsg_pti_id,
       fsg_icon_css,
       fsg_name_css,
       fsg_active
  from fsm_status_groups;

comment on table fsm_status_groups_tv is 'Language-neutral technical read contract for FSM_STATUS_GROUPS; all stored rows and columns';
comment on column fsm_status_groups_tv.fsg_id is 'Primary key';
comment on column fsm_status_groups_tv.fsg_fcl_id is 'Primary key, reference to FSM_CLASSES';
comment on column fsm_status_groups_tv.fsg_pti_id is 'Translatable item, reference to PIT_TRANSLATABLE_ITEM';
comment on column fsm_status_groups_tv.fsg_icon_css is 'Optional icon for controlling the display in reports';
comment on column fsm_status_groups_tv.fsg_name_css is 'Optional CSS class to control report display';
comment on column fsm_status_groups_tv.fsg_active is 'Flag indicating whether the status group is active or not';
