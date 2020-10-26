begin

  fsm_admin.merge_class(
    p_fcl_id => 'FSM',
    p_fcl_name => 'Finite State Machine',
    p_fcl_description => 'Abstract super class, defines interface');

  fsm_admin.merge_status_group(
    p_fsg_id => 'CANCELLED',
    p_fsg_fcl_id => 'FSM',
    p_fsg_name => 'Abgebrochen',
    p_fsg_description => 'Bearbeitung wurde abgebrochen');

  fsm_admin.merge_status_group(
    p_fsg_id => 'CLOSED',
    p_fsg_fcl_id => 'FSM',
    p_fsg_name => 'Abgeschlossen',
    p_fsg_description => 'Bearbeitung wurde abgeschlossen');

  fsm_admin.merge_status_group(
    p_fsg_id => 'ERROR',
    p_fsg_fcl_id => 'FSM',
    p_fsg_name => 'Fehler',
    p_fsg_description => 'Objekt hat einen Fehler');

  fsm_admin.merge_status_group(
    p_fsg_id => 'MANUAL',
    p_fsg_fcl_id => 'FSM',
    p_fsg_name => 'Manuell',
    p_fsg_description => 'Automatisierte Bearbeitung wurde abgelehnt');

  fsm_admin.merge_status_group(
    p_fsg_id => 'OPEN',
    p_fsg_fcl_id => 'FSM',
    p_fsg_name => 'In Bearbeitung',
    p_fsg_description => 'Objekt ist in Bearbeitung');

  fsm_admin.merge_status_group(
    p_fsg_id => 'WARNING',
    p_fsg_fcl_id => 'FSM',
    p_fsg_name => 'Warnung',
    p_fsg_description => 'Objekt hat eine Warnung');
    
  
  merge into fsm_status_severities s
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
      
      
  fsm_admin.merge_status(
    p_fst_id => 'ERROR',
    p_fst_fcl_id => 'FSM',
    p_fst_fsg_id => 'ERROR',
    p_fst_name => 'Error',
    p_fst_description => 'Process stopped due to an error',
    p_fst_msg_id => msg.FSM_FINAL_STATE);


  fsm_admin.merge_event(
    p_fev_id => 'ERROR',
    p_fev_fcl_id => 'FSM',
    p_fev_name => 'Error occurred',
    p_fev_description => 'Processing is stopped');

  fsm_admin.merge_event(
    p_fev_id => 'INITIALIZE',
    p_fev_fcl_id => 'FSM',
    p_fev_name => 'Initialize FSM',
    p_fev_description => 'Instance is initialized');

  fsm_admin.merge_event(
    p_fev_id => 'NIL',
    p_fev_fcl_id => 'FSM',
    p_fev_name => 'No action',
    p_fev_description => 'No further actions');
    
  commit;
  
end;
/
