create or replace view fsm_sub_classes_v as
select fsc_id, fsc_fcl_id, pti_name fsc_name, pti_description fsc_description, fsc_active
  from fsm_sub_classes
  join pit_translatable_item_v
    on fsc_pti_id = pti_id
   and fsc_fcl_id = pti_pmg_name;
 