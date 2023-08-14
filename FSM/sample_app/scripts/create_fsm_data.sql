begin

  fsm_admin.merge_class(
    p_fcl_id => 'REQ',
    p_fcl_name => 'Privilege Request',
    p_fcl_description => 'Request to be granted a database privilege');
    
  fsm_admin.merge_status(
    p_fst_id => 'GRANTED',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'REQ_GRANTED',
    p_fst_name => 'Granted',
    p_fst_description => 'Request was granted');
    
  fsm_admin.merge_status(
    p_fst_id => 'CREATED',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FSM_STATUS_CHANGED',
    p_fst_name => 'Request created',
    p_fst_description => 'Request has been created');
    
  fsm_admin.merge_status(
    p_fst_id => 'GRANT_AUTOMATICALLY',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FSM_STATUS_CHANGED',
    p_fst_name => 'Granted automatically',
    p_fst_description => 'Request my be granted automatically');
    
  fsm_admin.merge_status(
    p_fst_id => 'GRANT_MANUALLY',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'REQ_PENDING',
    p_fst_name => 'To be granted manually',
    p_fst_description => 'Request must be granted manually');
    
  fsm_admin.merge_status(
    p_fst_id => 'GRANT_SUPERVISOR',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'REQ_PENDING',
    p_fst_name => 'To be granted by Supervisor',
    p_fst_description => 'Request must be granted by supervisor');
    
  fsm_admin.merge_status(
    p_fst_id => 'IN_PROCESS',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FSM_STATUS_CHANGED',
    p_fst_name => 'Request in process',
    p_fst_description => 'Request is in process');
    
  fsm_admin.merge_status(
    p_fst_id => 'REJECTED',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'REQ_REJECTED',
    p_fst_name => 'Rejected',
    p_fst_description => 'Request was rejected');
    
  fsm_admin.merge_event(
    p_fev_id => 'CHECK',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'Check Request',
    p_fev_description => 'Check incoming request',
    p_fev_command_label => 'Check',
    p_fev_raised_by_user => false);
    
  fsm_admin.merge_event(
    p_fev_id => 'GRANT',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'Grant request',
    p_fev_description => 'Grant request',
    p_fev_command_label => 'Grant',
    p_fev_button_icon => 'fa-check fa-bg-green',
    p_fev_raised_by_user => true);
    
  fsm_admin.merge_event(
    p_fev_id => 'INITIALIZE',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'Initialize',
    p_fev_description => 'Initialize Request',
    p_fev_command_label => 'Initialize',
    p_fev_raised_by_user => false);
    
  fsm_admin.merge_event(
    p_fev_id => 'NIL',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'No Action',
    p_fev_description => 'No Action',
    p_fev_command_label => 'NIL',
    p_fev_raised_by_user => false);
    
  fsm_admin.merge_event(
    p_fev_id => 'REJECT',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'Reject Request',
    p_fev_description => 'Reject request',
    p_fev_command_label => 'Reject',
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
end;
/