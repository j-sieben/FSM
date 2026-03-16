create or replace view fsm_classes_v as
select fcl_id, pti_name fcl_name, pti_description fcl_description, fcl_type_name, fcl_active
  from fsm_classes
  join pit_translatable_item_v
    on fcl_pti_id = pti_id
   and fcl_id = pti_pmg_name
 where fcl_id = 'FSM'
    or exists (
         select 1
           from all_types typ
          where typ.type_name = upper(fcl_type_name)
       );
 
