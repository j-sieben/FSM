create or replace view bl_fsm_edges as
with params as (
        select /*+ no_merge */
               pit_util.C_TRUE C_TRUE,
               pit_util.C_FALSE C_FALSE
          from dual),
     edges as (
       select ftr.ftr_fcl_id fcl_id,
              ftr.ftr_fsc_id fsc_id,
              ftr.ftr_fst_id source_status_id,
              regexp_substr(ftr.ftr_fst_list, '[^:]+', 1, level) target_status_id,
              ftr.ftr_fev_id event_id,
              ftr.ftr_raise_automatically raise_automatically,
              ftr.ftr_raise_on_status raise_on_status
         from fsm_transitions ftr
        where ftr.ftr_active = pit_util.C_TRUE
      connect by regexp_substr(ftr.ftr_fst_list, '[^:]+', 1, level) is not null
             and prior sys_guid() is not null
             and prior ftr.rowid = ftr.rowid)
select e.fcl_id,
       e.fsc_id,
       e.source_status_id,
       src_pti.pti_name source_status_name,
       src.fst_initial_status source_is_initial,
       src.fst_terminal_status source_is_terminal,
       e.target_status_id,
       tgt_pti.pti_name target_status_name,
       tgt.fst_initial_status target_is_initial,
       tgt.fst_terminal_status target_is_terminal,
       e.event_id,
       fev_pti.pti_name event_name,
       e.raise_automatically,
       e.raise_on_status
  from edges e
  join fsm_status src
    on e.source_status_id = src.fst_id
   and e.fcl_id = src.fst_fcl_id
  join pit_translatable_item_v src_pti
    on src.fst_pti_id = src_pti.pti_id
   and src.fst_fcl_id = src_pti.pti_pmg_name
  join fsm_status tgt
    on e.target_status_id = tgt.fst_id
   and e.fcl_id = tgt.fst_fcl_id
  join pit_translatable_item_v tgt_pti
    on tgt.fst_pti_id = tgt_pti.pti_id
   and tgt.fst_fcl_id = tgt_pti.pti_pmg_name
  join fsm_events fev
    on e.event_id = fev.fev_id
   and e.fcl_id = fev.fev_fcl_id
  join pit_translatable_item_v fev_pti
    on fev.fev_pti_id = fev_pti.pti_id
   and fev.fev_fcl_id = fev_pti.pti_pmg_name
  join params
    on src.fst_active = C_TRUE
   and tgt.fst_active = C_TRUE
   and fev.fev_active = C_TRUE;

comment on table bl_fsm_edges is 'BL view providing normalized FSM graph edges';
