/**
  View: FSM_STATUS_SEVERITIES_TV
    Language-neutral, unfiltered technical read contract for <FSM_STATUS_SEVERITIES>.
    Explicit 1:1 projection; keys and stored payloads retain their table semantics.

  Dependencies:
    <FSM_STATUS_SEVERITIES> only; no translated lookups.
 */

create or replace view fsm_status_severities_tv as
select fss_id,
       fss_fcl_id,
       fss_pti_id,
       fss_html,
       fss_icon
  from fsm_status_severities;

comment on table fsm_status_severities_tv is 'Language-neutral technical read contract for FSM_STATUS_SEVERITIES; all stored rows and columns';
comment on column fsm_status_severities_tv.fss_id is 'Technical key, equivalent to the FSM.C_STORY_* constants';
comment on column fsm_status_severities_tv.fss_fcl_id is 'Technical Key. Message group. Defaults to FSM';
comment on column fsm_status_severities_tv.fss_pti_id is 'Severity name';
comment on column fsm_status_severities_tv.fss_html is 'HTML snippet, long form';
comment on column fsm_status_severities_tv.fss_icon is 'HTML snippet, status icon';
