create or replace view fsm_classes_v as
select fcl_id, pti_name fcl_name, pti_description fcl_description, fcl_active
  from fsm_classes
  join pit_translatable_item_v
    on fcl_id = pti_id
   and fcl_id = pti_pmg_name;
 