create or replace view fsm_status_severities_v as
select fss_id, fss_fcl_id, pti_name fss_name, pti_display_name fss_display_name,
       pti_description fss_description, fss_html, fss_icon
  from fsm_status_severities
  join pit_translatable_item_v
    on fss_pti_id = pti_id
   and fss_fcl_id = pti_pmg_name;
 
comment on table fsm_status_severities_v  is 'Table to store fsm status definitions per class type';
comment on column fsm_status_severities_v.fss_id is 'Primary key';
comment on column fsm_status_severities_v.fss_fcl_id is 'Primary key, reference to FSM_CLASSES';
comment on column fsm_status_severities_v.fss_name is 'Technical severity name';
comment on column fsm_status_severities_v.fss_display_name is 'Display name for reports and user interfaces';
comment on column fsm_status_severities_v.fss_description is 'Optional description';
comment on column fsm_status_severities_v.fss_html is 'Optional HTML snippet or CSS option';
comment on column fsm_status_severities_v.fss_icon is 'Optional icon CSS class resp. url to an icon.';
