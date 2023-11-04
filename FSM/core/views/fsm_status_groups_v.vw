create or replace view fsm_status_groups_v as
select fsg_id, fsg_fcl_id, pti_name fsg_name, pti_description fsg_description,
       fsg_icon_css, fsg_name_css, fsg_active
  from fsm_status_groups
  join pit_translatable_item_v
    on fsg_pti_id = pti_id
   and fsg_fcl_id = pti_pmg_name;
 
comment on table fsm_status_groups_v  is 'Table to store fsm status definitions per class type';
comment on column fsm_status_groups_v.fsg_id is 'Primary key';
comment on column fsm_status_groups_v.fsg_fcl_id is 'Primary key, reference to FSM_CLASSES';
comment on column fsm_status_groups_v.fsg_name is 'Descriptive name for LOV';
comment on column fsm_status_groups_v.fsg_description is 'Optional description';
comment on column fsm_status_groups_v.fsg_icon_css is 'Optional CSS class';
comment on column fsm_status_groups_v.fsg_name_css is 'Optional css class resp. url to an icon.';
comment on column fsm_status_groups_v.fsg_active is 'Flag to indicate whether status is in use actually.';