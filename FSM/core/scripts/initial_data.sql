

merge into fsm_class c
using (select 'FSM' fcl_id, 
              'Finite State Machine' fcl_name,
              'Abstracdt super class, defines interface' fcl_description
         from dual) v
   on (c.fcl_id = v.fcl_id)
 when not matched then insert(fcl_id, fcl_name, fcl_description)
      values(v.fcl_id, v.fcl_name, v.fcl_description);
      
commit;

merge into fsm_status_group g
using (select 'CANCELLED' fsg_id,
              'Abgebrochen' fsg_name,
              'Bearbeitung wurde abgebrochen' fsg_description
         from dual
       union all
       select 'CLOSED', 'Abgeschlossen', 'Bearbeitung wurde abgeschlossen' from dual union all
       select 'ERROR', 'Fehler', 'Objekt hat einen Fehler' from dual union all
       select 'MANUAL', 'Manuell', 'Automatisierte Bearbeitung wurde abgelehnt' from dual union all
       select 'OPEN', 'In Bearbeitung', 'Objekt ist in Bearbeitung' from dual union all
       select 'WARNING', 'Warnung', 'Objekt hat eine Warnung' from dual) v
   on (g.fsg_id = v.fsg_id)
 when matched then update set
      fsg_name = v.fsg_name, 
      fsg_description = v.fsg_description,
      fsg_active = 'Y'
 when not matched then insert(fsg_id, fsg_name, fsg_description)
      values (v.fsg_id, v.fsg_name, v.fsg_description);

commit;


merge into fsm_status_severity s
using (select 30 fss_id,
              'Error' fss_name,
              '<span class="fa-bg-red">Error</span>' fss_html,
              '<i class="fa fa-times fa-text-red"/>' fss_status
         from dual 
       union all
       select 40, 'Warning', '<span class="fa-bg-yellow">Warning</span>', '<i class="fa fa-exclamation-triangle fa-text-red"/>' from dual union all
       select 50, 'Milestone', '<span class="fa-bg-green">Milestone</span>', '<i class="fa fa-check fa-text-green"/>' from dual union all
       select 60, 'Information', '<span>Information</span>', '<i class="fa fa-check fa-text-green"/>' from dual union all
       select 70, 'Additional Info', '	<span>Additional Info</span>', '<i class="fa fa-check fa-text-green"/>' from dual) v
   on (s.fss_id = v.fss_id)
 when not matched then insert(fss_id, fss_name, fss_html, fss_status)
      values(v.fss_id, v.fss_name, v.fss_html, v.fss_status);
      
commit;


merge into fsm_status c
using (select 'ERROR' fst_id,
              'FSM' fst_fcl_id,
              'ERROR' fst_fsg_id,
              'FSM_FINAL_STATE' fst_msg_id,
              'Error' fst_name,
              'Process stopped due to an error' fst_description,
              0 fst_retries_on_error,
              null fst_retry_schedule,
              null fst_retry_time
         from dual) v
   on (c.fst_id = v.fst_id)
 when matched then update set
      fst_fsg_id = v.fst_fsg_id,
      fst_msg_id = v.fst_msg_id,
      fst_description = v.fst_description
 when not matched then insert(fst_id, fst_fcl_id, fst_fsg_id, fst_msg_id, fst_name, fst_description, fst_retries_on_error, fst_retry_schedule, fst_retry_time)
      values(v.fst_id, v.fst_fcl_id, v.fst_fsg_id, v.fst_msg_id, v.fst_name, v.fst_description, v.fst_retries_on_error, v.fst_retry_schedule, v.fst_retry_time);
      
commit;


merge into fsm_event e
using (select 'ERROR' fev_id,
              'FSM' fev_fcl_id,
              'FSM_EVENT_RAISED' fev_msg_id,
              'Error occurred' fev_name,
              'Processing is stopped' fev_description,
              'Error occurred' fev_command,
              'Y' fev_active
         from dual
        union all
       select 'INITIALIZE', 'FSM', 'FSM_EVENT_RAISED', 'initialize fsm', 'Instance is initialized', 'Initialize', 'Y' from dual union all
       select 'NIL', 'FSM', 'FSM_EVENT_RAISED', 'No action', 'no further actions', 'No action', 'Y' from dual) v
   on (e.fev_id = v.fev_id)
 when not matched then insert (
        fev_id, fev_fcl_id, fev_msg_id, fev_name, fev_description, fev_command, fev_active)
      values (
        v.fev_id, v.fev_fcl_id, v.fev_msg_id, v.fev_name, v.fev_description, v.fev_command, v.fev_active);

commit;
