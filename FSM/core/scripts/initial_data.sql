begin

  fsm_admin.merge_class(
    p_fcl_id => 'FSM',
    p_fcl_type_name => 'FSM_TYPE',
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
    p_fss_id => fsm.C_STORY_ERROR,
    p_fss_fcl_id => 'FSM',
    p_fss_name => 'ERROR',
    p_fss_display_name => 'Fehler',
    p_fss_description => 'Endstatus eines Flows mit Fehler.',
    p_fss_html => 'u-danger',
    p_fss_icon => 'fa-exclamation-circle');
    
  fsm_admin.merge_status_severity(
    p_fss_id => fsm.C_STORY_TERMINAL,
    p_fss_fcl_id => 'FSM',
    p_fss_name => 'TERMINAL',
    p_fss_display_name => 'Beendet',
    p_fss_description => 'Endstatus eines Flows.',
    p_fss_html => 'u-success',
    p_fss_icon => 'fa-flag-checkered');
    
  fsm_admin.merge_status_severity(
    p_fss_id => fsm.C_STORY_MILESTONE,
    p_fss_fcl_id => 'FSM',
    p_fss_name => 'MILESTONE',
    p_fss_display_name => 'Meilenstein',
    p_fss_description => 'Relevanter Zwischenschritt eines Flows.',
    p_fss_html => 'u-success',
    p_fss_icon => 'fa-stop-circle');
    
  fsm_admin.merge_status_severity(
    p_fss_id => fsm.C_STORY_RESULT,
    p_fss_fcl_id => 'FSM',
    p_fss_name => 'RESULT',
    p_fss_display_name => 'Ergebnis',
    p_fss_description => 'Ergebnis eines Bearbeitungsschritts.',
    p_fss_html => 'u-success',
    p_fss_icon => 'fa-check');
    
  fsm_admin.merge_status_severity(
    p_fss_id => fsm.C_STORY_STEP,
    p_fss_fcl_id => 'FSM',
    p_fss_name => 'STEP',
    p_fss_display_name => 'Teilschritt',
    p_fss_description => 'Bearbeitungsschritt.',
    p_fss_html => 'u-info',
    p_fss_icon => 'fa-dot-circle-o');

  fsm_admin.merge_status_severity(
    p_fss_id => fsm.C_STORY_TRANSITION,
    p_fss_fcl_id => 'FSM',
    p_fss_name => 'TRANSITION',
    p_fss_display_name => 'Statuswechsel',
    p_fss_description => 'Statuswechsel eines Bearbeitungsschritts.',
    p_fss_html => 'u-info',
    p_fss_icon => 'fa-arrow-right');

  fsm_admin.merge_status_severity(
    p_fss_id => fsm.C_STORY_DETAIL,
    p_fss_fcl_id => 'FSM',
    p_fss_name => 'DETAIL',
    p_fss_display_name => 'Detail',
    p_fss_description => 'Sonstige Meldungen eines Bearbeitungsschritts.',
    p_fss_html => 'u-normal',
    p_fss_icon => 'fa-list-alt');
      
  fsm_admin.merge_status(
    p_fst_id => 'ERROR',
    p_fst_fcl_id => 'FSM',
    p_fst_fsg_id => 'ERROR',
    p_fst_name => 'Fehler',
    p_fst_description => 'Prozess aufgrund eines Fehlers gestoppt',
    p_fst_severity => fsm.C_STORY_ERROR,
    p_fst_msg_id => msg.FSM_FINAL_STATE,
    p_fst_terminal_status => true);


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
end;
/
