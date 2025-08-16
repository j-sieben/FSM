create or replace view bl_fsm_hierarchy as
with params as (
       select /*+ no_merge */ pit_util.C_TRUE C_TRUE
         from dual)
 select level lvl,
        connect_by_iscycle zirkel,
        ftr_fcl_id class,
        case
          when fst_retries_on_error = 0 then 'Keine Wdhlg.'
          when fst_retry_schedule is not null then fst_retries_on_error || ' Wdhlg., Schedule ' || fst_retry_schedule
          when fst_retry_time is not null then fst_retries_on_error || ' Wdhlg., Wartezeit ' || fst_retry_time || ' Sek.'
          else fst_retries_on_error || ' Wdhlg.' end versuche,
          lpad('.', (level - 1), '.') || case ftr_raise_on_status
          when 0 then 'wenn ' || prior ftr_fev_id || ' OK:'
          else 'bei Fehler:' end on_error,
        ftr_fst_id status,
        case
          when connect_by_isleaf = 1 then 'beende mit'
          when ftr_raise_automatically = C_TRUE then 'weiter mit'
          else 'warte, dann' end automatic,
        ftr_fev_id event,
        fst_description status_beschreibung,
        fev_description event_beschreibung
   from (select ftr_fcl_id, ftr_fst_id, ftr_fst_list, 
                ftr_fev_id, fev_description, fst_description, c_true, fst_initial_status,
                fst_retries_on_error, fst_retry_schedule, fst_retry_time, ftr_raise_on_status, ftr_raise_automatically
           from fsm_transitions_v
           join fsm_status_v fst
             on ftr_fst_id = fst_id
            and ftr_fcl_id = fst_fcl_id
           join fsm_events_v fev
             on ftr_fev_id = fev_id
            and ftr_fcl_id = fev_fcl_id
           join params
             on ftr_active = C_TRUE
            and fst_active = C_TRUE
            and fev_active = C_TRUE) ftr
  start with fst_initial_status = C_TRUE
connect by nocycle instr(prior ftr_fst_list, ftr_fst_id) > 0 and ftr_fcl_id = prior ftr_fcl_id
  order siblings by ftr_fst_id;
  
comment on table bl_fsm_hierarchy is 'Generic hierarchical query to visualize the logical flow of a FSM flow';
