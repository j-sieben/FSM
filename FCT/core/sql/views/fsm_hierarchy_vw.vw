create or replace force view &TOOLKIT._hierarchy_vw as 
select level lvl,
        connect_by_iscycle zirkel,
        ftr_fcl_id class,
        case
        when fst_retries_on_error = 0 then 'Keine Wdhlg.'
        when fst_retry_schedule is not null then fst_retries_on_error || ' Wdhlg., Schedule ' || fst_retry_schedule
        when fst_retry_time is not null then fst_retries_on_error || ' Wdhlg., Wartezeit ' || fst_retry_time || ' Sek.'
        else fst_retries_on_error || ' Wdhlg.' end versuche,
        lpad('.', (level - 1), '.') || case ftr_raise_on_status
        when 0 then 'wenn ' || prior fev_id || ' OK:'
        else 'bei Fehler:' end on_error,
        ftr_fst_id status,
        case
        when connect_by_isleaf = 1 then 'beende mit'
        when ftr_raise_automatically = 'Y' then 'weiter mit'
        else 'warte, dann' end automatic,
        ftr_fev_id event,
        fst_description status_beschreibung,
        fev_description event_beschreibung
   from (select ftr.*,
                fst.*,
                fev.*
           from &TOOLKIT._transition ftr
           join &TOOLKIT._status fst on ftr.ftr_fst_id = fst.fst_id and ftr_fcl_id = fst_fcl_id
           join &TOOLKIT._event fev on ftr.ftr_fev_id = fev.fev_id and ftr_fcl_id = fev_fcl_id
          where ftr.ftr_active = 'Y'
            and fst.fst_active = 'Y'
            and fev.fev_active = 'Y') ftr
  start with ftr_fst_id in ('CREATED', 'IMPORTED')
connect by nocycle instr(prior ftr_fst_list, ftr_fst_id) > 0 and ftr_fcl_id = prior ftr_fcl_id
  order siblings by ftr_fst_id;

