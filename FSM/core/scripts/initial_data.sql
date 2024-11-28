begin

  fsm_admin.merge_class(
    p_fcl_id => 'FSM',
    p_fcl_name => 'Finite State Machine',
    p_fcl_description => 'Abstrakte Superklasse, definiert Schnittstelle');

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
    
    
  fsm_admin.merge_status_severity(
    p_fss_id => 30,
    p_fss_fcl_id => 'FSM',
    p_fss_name => 'Fehler',
    p_fss_description => 'Fehler, die zum Abbruch der Aktion führen.',
    p_fss_html => '<span class="fa-bg-red">Error</span>',
    p_fss_icon => '<i class="fa fa-times u-color-danger"/>');
    
  fsm_admin.merge_status_severity(
    p_fss_id => 40,
    p_fss_fcl_id => 'FSM',
    p_fss_name => 'Warnung',
    p_fss_description => 'Warnmeldungen, die während der Ausführung ausgelöst wurden',
    p_fss_html => '<span class="fa-bg-yellow">Warning</span>',
    p_fss_icon => '<i class="fa fa-exclamation-triangle u-color-warning"/>');
    
  fsm_admin.merge_status_severity(
    p_fss_id => 50,
    p_fss_fcl_id => 'FSM',
    p_fss_name => 'Meilenstein',
    p_fss_description => 'Meilensteine, die wichtige Zwischenziele markieren',
    p_fss_html => '<span class="fa-bg-green">Milestone</span>',
    p_fss_icon => '<i class="fa fa-check u-color-success"/>');
    
  fsm_admin.merge_status_severity(
    p_fss_id => 60,
    p_fss_fcl_id => 'FSM',
    p_fss_name => 'Information',
    p_fss_description => 'Teilschritte, die keinen Meilenstein darstellen',
    p_fss_html => '<span>Information</span>',
    p_fss_icon => '<i class="fa fa-check u-color-success"/>');
    
  fsm_admin.merge_status_severity(
    p_fss_id => 70,
    p_fss_fcl_id => 'FSM',
    p_fss_name => 'Zusatzinformation',
    p_fss_description => 'Kleinere Teilschritte',
    p_fss_html => '<span>Zusatzinformation</span>',
    p_fss_icon => '<i class="fa fa-check u-color-success"/>');
      
  fsm_admin.merge_status(
    p_fst_id => 'ERROR',
    p_fst_fcl_id => 'FSM',
    p_fst_fsg_id => 'ERROR',
    p_fst_name => 'Fehler',
    p_fst_description => 'Prozess aufgrund eines Fehlers gestoppt',
    p_fst_severity => 30,
    p_fst_msg_id => msg.FSM_FINAL_STATE);


  fsm_admin.merge_event(
    p_fev_id => 'ERROR',
    p_fev_fcl_id => 'FSM',
    p_fev_name => 'Ein Fehler ist aufgetreten',
    p_fev_description => 'Die Verarbeitung wird gestoppt');

  fsm_admin.merge_event(
    p_fev_id => 'INITIALIZE',
    p_fev_fcl_id => 'FSM',
    p_fev_name => 'Initialisiere FSM',
    p_fev_description => 'Instanz wurde initialisiert');

  fsm_admin.merge_event(
    p_fev_id => 'NIL',
    p_fev_fcl_id => 'FSM',
    p_fev_name => 'Keine Aktion',
    p_fev_description => 'Keine weiteren Aktionen');
    
  commit;
  
  fsm_admin.create_event_package;
  fsm_admin.create_status_package;
  
end;
/
