/**
  View: FSM_SUB_CLASSES_TV
    Language-neutral, unfiltered technical read contract for <FSM_SUB_CLASSES>.
    Explicit 1:1 projection; keys and stored payloads retain their table semantics.

  Dependencies:
    <FSM_SUB_CLASSES> only; no translated lookups.
 */

create or replace view fsm_sub_classes_tv as
select fsc_id,
       fsc_fcl_id,
       fsc_pti_id,
       fsc_active
  from fsm_sub_classes;

comment on table fsm_sub_classes_tv is 'Language-neutral technical read contract for FSM_SUB_CLASSES; all stored rows and columns';
comment on column fsm_sub_classes_tv.fsc_id is 'Primary key';
comment on column fsm_sub_classes_tv.fsc_fcl_id is 'Primary key, Reference to FSM_CLASSES, constrains the subclass per class';
comment on column fsm_sub_classes_tv.fsc_pti_id is 'Translatable item, reference to PIT_TRANSLATABLE_ITEM';
comment on column fsm_sub_classes_tv.fsc_active is 'Flag indicating whether the class is currently used';
