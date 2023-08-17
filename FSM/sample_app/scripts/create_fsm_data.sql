begin

  fsm_admin.merge_class(
    p_fcl_id => 'REQ',
    p_fcl_name => 'Berechtigungsanforderung',
    p_fcl_description => 'Anforderung für eine Datenbankberechtigung');
    
  fsm_admin.merge_status(
    p_fst_id => 'GRANTED',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'REQ_GRANTED',
    p_fst_name => 'Genehmigt',
    p_fst_description => 'Die Anfrage wurde genehmigt');
    
  fsm_admin.merge_status(
    p_fst_id => 'CREATED',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FSM_STATUS_CHANGED',
    p_fst_name => 'Antrag erstellt',
    p_fst_description => 'Der Antrag wurde erstellt');
    
  fsm_admin.merge_status(
    p_fst_id => 'GRANT_AUTOMATICALLY',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FSM_STATUS_CHANGED',
    p_fst_name => 'Automatisch genehmigt',
    p_fst_description => 'Der Antrag wurde automatisiert genehmigt');
    
  fsm_admin.merge_status(
    p_fst_id => 'GRANT_MANUALLY',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'REQ_PENDING',
    p_fst_name => 'Antrag muss genehmigt werden',
    p_fst_description => 'Diese Beantragung muss genehmigt werden');
    
  fsm_admin.merge_status(
    p_fst_id => 'GRANT_SUPERVISOR',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'REQ_PENDING',
    p_fst_name => 'Erteilung durch Supervisor',
    p_fst_description => 'Deise Beantragung muss durch einen Supervisor genehmigt werden');
    
  fsm_admin.merge_status(
    p_fst_id => 'IN_PROCESS',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FSM_STATUS_CHANGED',
    p_fst_name => 'In Bearbeitung',
    p_fst_description => 'Der Antrag wird bearbeitet');
    
  fsm_admin.merge_status(
    p_fst_id => 'REJECTED',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'REQ_REJECTED',
    p_fst_name => 'Abgelehnt',
    p_fst_description => 'Der Antrag wurde abgelehnt');
    
  fsm_admin.merge_event(
    p_fev_id => 'CHECK',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'Prüfe Antrag',
    p_fev_description => 'Der eingegangene Antrag wird geprüft',
    p_fev_command_label => 'Prüfen',
    p_fev_raised_by_user => false);
    
  fsm_admin.merge_event(
    p_fev_id => 'GRANT',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'Antrag genehmigen',
    p_fev_description => 'Antrag wird genehmigt',
    p_fev_command_label => 'Genehmigen',
    p_fev_button_icon => 'fa-check fa-bg-green',
    p_fev_raised_by_user => true);
    
  fsm_admin.merge_event(
    p_fev_id => 'INITIALIZE',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'Initialisieren',
    p_fev_description => 'Initialisiere Antrag',
    p_fev_command_label => 'Initialisieren',
    p_fev_raised_by_user => false);
    
  fsm_admin.merge_event(
    p_fev_id => 'NIL',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'Keine Aktion',
    p_fev_description => 'Keine Aktion',
    p_fev_command_label => 'NIL',
    p_fev_raised_by_user => false);
    
  fsm_admin.merge_event(
    p_fev_id => 'REJECT',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'Antrag ablehnen',
    p_fev_description => 'Antrag abgelehnt',
    p_fev_command_label => 'Ablehnen',
    p_fev_button_icon => 'fa-close fa-bg-red',
    p_fev_raised_by_user => true);
    
  fsm_admin.merge_transition(
    p_ftr_fst_id => 'CREATED',
    p_ftr_fev_id => 'INITIALIZE',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'IN_PROCESS',
    p_ftr_raise_automatically => true);
    
  fsm_admin.merge_transition(
    p_ftr_fst_id => 'IN_PROCESS',
    p_ftr_fev_id => 'CHECK',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'GRANT_AUTOMATICALLY:GRANT_MANUALLY:GRANT_SUPERVISOR',
    p_ftr_raise_automatically => true);
    
  fsm_admin.merge_transition(
    p_ftr_fst_id => 'GRANT_AUTOMATICALLY',
    p_ftr_fev_id => 'GRANT',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'GRANTED',
    p_ftr_raise_automatically => true);
    
  fsm_admin.merge_transition(
    p_ftr_fst_id => 'GRANT_MANUALLY',
    p_ftr_fev_id => 'GRANT',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'GRANTED',
    p_ftr_raise_automatically => false);
    
  fsm_admin.merge_transition(
    p_ftr_fst_id => 'GRANT_SUPERVISOR',
    p_ftr_fev_id => 'GRANT',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'GRANTED',
    p_ftr_required_role => 'SUPERVISOR',
    p_ftr_raise_automatically => false);
    
  fsm_admin.merge_transition(
    p_ftr_fst_id => 'GRANT_MANUALLY',
    p_ftr_fev_id => 'REJECT',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'REJECTED',
    p_ftr_raise_automatically => false);
    
  fsm_admin.merge_transition(
    p_ftr_fst_id => 'GRANT_SUPERVISOR',
    p_ftr_fev_id => 'REJECT',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'REJECTED',
    p_ftr_required_role => 'SUPERVISOR',
    p_ftr_raise_automatically => false);
    
  fsm_admin.merge_transition(
    p_ftr_fst_id => 'GRANTED',
    p_ftr_fev_id => 'NIL',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => '',
    p_ftr_raise_automatically => false);
    
  fsm_admin.merge_transition(
    p_ftr_fst_id => 'REJECTED',
    p_ftr_fev_id => 'NIL',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => '',
    p_ftr_raise_automatically => false);
  
  commit;
  
  fsm_admin.create_event_package;
  fsm_admin.create_status_package;
end;
/