create or replace view fsm_status_severities_v as
select fss_id, fss_fcl_id, pti_name fss_name, pti_description fss_description,
       fss_html, fss_icon
  from fsm_status_severities
  join pit_translatable_item_v
    on fss_pti_id = pti_id
   and fss_fcl_id = pti_pmg_name;
 
comment on table fsm_status_severities_v  is 'Table to store fsm status definitions per class type';
comment on column fsm_status_severities_v.fss_id is 'Primary key';
comment on column fsm_status_severities_v.fss_fcl_id is 'Primary key, reference to FSM_CLASSES';
comment on column fsm_status_severities_v.fss_name is 'Descriptive name for LOV';
comment on column fsm_status_severities_v.fss_description is 'Optional description';
comment on column fsm_status_severities_v.fss_html is 'Optional CSS class';
comment on column fsm_status_severities_v.fss_icon is 'Optional css class resp. url to an icon.';