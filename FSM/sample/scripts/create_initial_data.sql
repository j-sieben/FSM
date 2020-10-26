begin

  merge into demo_user u
  using (select 'NORMAL_USER' usr_id,
                'Normal User' usr_name,
                'User with normla user rights' usr_description,
                'USER' usr_role
           from dual
         union all
         select 'SUPERVISOR', 'Supervisor', 'User with Supervisor role', 'SUPERVISOR' from dual) v
     on (u.usr_id = v.usr_id)
   when not matched then insert(usr_id, usr_name, usr_description, usr_role)
        values(v.usr_id, v.usr_name, v.usr_description, v.usr_role);
        
  commit;
  
  
  bl_fsm_pkg.merge_request_type(
    p_rtp_id => 'OBJECT_PRIV',
    p_rtp_name => 'Object privilege',
    p_rtp_description => 'Request to be granted an object privilege');
    
  bl_fsm_pkg.merge_request_type(
    p_rtp_id => 'SYSTEM_PRIV',
    p_rtp_name => 'System privilege',
    p_rtp_description => 'Request to be granted a system privilege');
  
  commit;

  bl_fsm_pkg.merge_requestor(
    p_rre_id => 'JOHNDOE',
    p_rre_name => 'John Doe',
    p_rre_description => 'Developer');
    
  bl_fsm_pkg.merge_requestor(
    p_rre_id => 'PATABALLA',
    p_rre_name => 'Valli Pataballa',
    p_rre_description => 'Developer');
  
  commit;

  fsm_admin_pkg.merge_class(
    p_fcl_id => 'REQ',
    p_fcl_name => 'Privilege Request',
    p_fcl_description => 'Request to be granted a database privilege');
    
  commit;
    
  fsm_admin_pkg.merge_status(
    p_fst_id => 'GRANTED',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FSM_REQ_GRANTED',
    p_fst_name => 'Granted',
    p_fst_description => 'Request was granted');
    
  fsm_admin_pkg.merge_status(
    p_fst_id => 'CREATED',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FSM_STATUS_CHANGED',
    p_fst_name => 'Request created',
    p_fst_description => 'Request has been created');
    
  fsm_admin_pkg.merge_status(
    p_fst_id => 'GRANT_AUTOMATICALLY',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FSM_STATUS_CHANGED',
    p_fst_name => 'Granted automatically',
    p_fst_description => 'Request my be granted automatically');
    
  fsm_admin_pkg.merge_status(
    p_fst_id => 'GRANT_MANUALLY',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FSM_REQ_PENDING',
    p_fst_name => 'To be granted manually',
    p_fst_description => 'Request must be granted manually');
    
  fsm_admin_pkg.merge_status(
    p_fst_id => 'GRANT_SUPERVISOR',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FSM_REQ_PENDING',
    p_fst_name => 'To be granted by Supervisor',
    p_fst_description => 'Request must be granted by supervisor');
    
  fsm_admin_pkg.merge_status(
    p_fst_id => 'IN_PROCESS',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FSM_STATUS_CHANGED',
    p_fst_name => 'Request in process',
    p_fst_description => 'Request is in process');
    
  fsm_admin_pkg.merge_status(
    p_fst_id => 'REJECTED',
    p_fst_fsg_id => null,
    p_fst_fcl_id => 'REQ',
    p_fst_msg_id => 'FSM_REQ_REJECTED',
    p_fst_name => 'Rejected',
    p_fst_description => 'Request was rejected');
    
  commit;
    
  fsm_admin_pkg.merge_event(
    p_fev_id => 'CHECK',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'Check Request',
    p_fev_description => 'Check incoming request',
    p_fev_command => 'Check',
    p_fev_raised_by_user => false);
    
  fsm_admin_pkg.merge_event(
    p_fev_id => 'GRANT',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'Grant request',
    p_fev_description => 'Grant request',
    p_fev_command => 'Grant',
    p_fev_button_icon => 'fa-check fa-bg-green',
    p_fev_raised_by_user => true);
    
  fsm_admin_pkg.merge_event(
    p_fev_id => 'INITIALIZE',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'Initialize',
    p_fev_description => 'Initialize Request',
    p_fev_command => 'Initialize',
    p_fev_raised_by_user => false);
    
  fsm_admin_pkg.merge_event(
    p_fev_id => 'NIL',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'No Action',
    p_fev_description => 'No Action',
    p_fev_command => 'NIL',
    p_fev_raised_by_user => false);
    
  fsm_admin_pkg.merge_event(
    p_fev_id => 'REJECT',
    p_fev_fcl_id => 'REQ',
    p_fev_msg_id => 'FSM_EVENT_RAISED',
    p_fev_name => 'Reject Request',
    p_fev_description => 'Reject request',
    p_fev_command => 'Reject',
    p_fev_button_icon => 'fa-close fa-bg-red',
    p_fev_raised_by_user => true);
    
  commit;
    
  fsm_admin_pkg.merge_transition(
    p_ftr_fst_id => 'CREATED',
    p_ftr_fev_id => 'INITIALIZE',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'IN_PROCESS',
    p_ftr_raise_automatically => true);
    
  fsm_admin_pkg.merge_transition(
    p_ftr_fst_id => 'IN_PROCESS',
    p_ftr_fev_id => 'CHECK',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'GRANT_AUTOMATICALLY:GRANT_MANUALLY:GRANT_SUPERVISOR',
    p_ftr_raise_automatically => true);
    
  fsm_admin_pkg.merge_transition(
    p_ftr_fst_id => 'GRANT_AUTOMATICALLY',
    p_ftr_fev_id => 'GRANT',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'GRANTED',
    p_ftr_raise_automatically => true);
    
  fsm_admin_pkg.merge_transition(
    p_ftr_fst_id => 'GRANT_MANUALLY',
    p_ftr_fev_id => 'GRANT',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'GRANTED',
    p_ftr_raise_automatically => false);
    
  fsm_admin_pkg.merge_transition(
    p_ftr_fst_id => 'GRANT_SUPERVISOR',
    p_ftr_fev_id => 'GRANT',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'GRANTED',
    p_ftr_required_role => 'SUPERVISOR',
    p_ftr_raise_automatically => false);
    
  fsm_admin_pkg.merge_transition(
    p_ftr_fst_id => 'GRANT_MANUALLY',
    p_ftr_fev_id => 'REJECT',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'REJECTED',
    p_ftr_raise_automatically => false);
    
  fsm_admin_pkg.merge_transition(
    p_ftr_fst_id => 'GRANT_SUPERVISOR',
    p_ftr_fev_id => 'REJECT',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => 'REJECTED',
    p_ftr_required_role => 'SUPERVISOR',
    p_ftr_raise_automatically => false);
    
  fsm_admin_pkg.merge_transition(
    p_ftr_fst_id => 'GRANTED',
    p_ftr_fev_id => 'NIL',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => '',
    p_ftr_raise_automatically => false);
    
  fsm_admin_pkg.merge_transition(
    p_ftr_fst_id => 'REJECTED',
    p_ftr_fev_id => 'NIL',
    p_ftr_fcl_id => 'REQ',
    p_ftr_fst_list => '',
    p_ftr_raise_automatically => false);
  
  commit;
end;
/