/**
  View: FSM_CLASSES_TV
    Language-neutral, unfiltered technical read contract for <FSM_CLASSES>.
    Explicit 1:1 projection; keys and stored payloads retain their table semantics.

  Dependencies:
    <FSM_CLASSES> only; no translated lookups.
 */

create or replace view fsm_classes_tv as
select fcl_id,
       fcl_pti_id,
       fcl_type_name,
       fcl_active
  from fsm_classes;

comment on table fsm_classes_tv is 'Language-neutral technical read contract for FSM_CLASSES; all stored rows and columns';
comment on column fsm_classes_tv.fcl_id is 'Primary key';
comment on column fsm_classes_tv.fcl_pti_id is 'Translatable item, reference to PIT_TRANSLATABLE_ITEM';
comment on column fsm_classes_tv.fcl_type_name is 'Name of the implementing SQL object type. Used to derive class ownership from ALL_TYPES.';
comment on column fsm_classes_tv.fcl_active is 'Flag indicating whether the class is currently used';
