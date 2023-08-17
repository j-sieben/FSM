create or replace package body fsm_req
as
  /**
    Package: FSM_REQ Body
      Package to implement the FSM related logic for requests

    Author::
      Juergen Sieben, ConDeS GmbH

   */

  C_FCL_ID constant char(3 byte) := 'REQ';

  g_result binary_integer;
  
  /**
    Group: Helper-Methods
   */
  /**
    Procedure: persist
      Method to persist an instance or changes for an instance
      
    Parameter:
      p_req - Instance of FSM_REQ_TYPE to persist
   */
  procedure persist(
    p_req in out nocopy fsm_req_type)
  as
  begin
    pit.enter_optional('persist');

    -- propagation to abstract super class
    fsm.persist(p_req);

    -- merge concrete instance attributes in table fsm_requests by calling its XAPI
    bl_request.merge_request(
      p_req_id => p_req.fsm_id,
      p_req_rtp_id => p_req.req_rtp_id,
      p_req_rre_id => p_req.req_rre_id,
      p_req_text => p_req.req_text);

    commit;

    pit.leave_optional;
  end persist;
  
  
  /**
    Group: Event-Handlers
   */
  /**
    Function: raise_default
      Generic event handler, just proceeds to the next possible event.
      
    Parameters:
      p_req - Instance of FSM_REQ_TYPE
      p_fev_id - Event to throw
      
    Returns:
      One of the constants FSM.C_OK or FSM.C_ERROR indicating whether the event could be raised successfully
      
    Throws:
      msg.FSM_NEXT_STATUS_NU_ERR - if more than one next status is possible.
             This error must be circumvented by creating a separate event handler
             which deterministically decides on the next status
   */
  function raise_default(
    p_req in out nocopy fsm_req_type,
    p_fev_id in varchar2)
    return binary_integer
  as
  begin
    pit.enter_optional('raise_default',
      p_params => msg_params(msg_param('p_fev_id', p_fev_id)));
    
    p_req.fsm_validity := fsm.C_OK;
    
    pit.leave_optional;
    return p_req.set_status(fsm.get_next_status(p_req, p_fev_id));
  end raise_default;
  
  
  /**
    Function: raise_check
      Decides how the decision on granting rights must be made.
      
    Parameter:
      p_req - Instance of FSM_REQ_TYPE
      
    Returns:
      One of the constants FSM.C_OK or FSM.C_ERROR indicating whether the event could be raised successfully
      
    Throws:
      msg.FSM_NEXT_STATUS_NU_ERR - if more than one next status is possible.
             This error must be circumvented by creating a separate event handler
             which deterministically decides on the next status
   */
  function raise_check(
    p_req in out nocopy fsm_req_type)
    return binary_integer
  as
    l_new_status fsm_status_v.fst_id%type;
    l_mode pls_integer;
  begin
    pit.enter_optional('raise_check');
    
    g_result := fsm.C_OK;
    -- Don't implement decision logic here, rather call an external business logic package
    -- or delegate to a decision table
    l_mode := bl_request.get_grant_mode(
                p_rtp_id => p_req.req_rtp_id,
                p_rre_id => p_req.req_rre_id);
                
    case l_mode
    when bl_request.C_GRANT_AUTOMATICALLY then
      l_new_status := fsm_fst.REQ_GRANT_AUTOMATICALLY;
    when bl_request.C_GRANT_MANUALLY then
      l_new_status := fsm_fst.REQ_GRANT_MANUALLY;
    else
      l_new_status := fsm_fst.REQ_GRANT_SUPERVISOR;
    end case;
    
    p_req.fsm_validity := g_result;
    
    pit.leave_optional;
    return p_req.set_status(l_new_status);
  end raise_check;
  
  
  /**
    Function: raise_nil
      Does nothing.
      
    Parameter:
      p_req - Instance of FSM_REQ_TYPE
      
    Returns:
      One of the constants FSM.C_OK or FSM.C_ERROR indicating whether the event could be raised successfully
      
    Throws:
      msg.FSM_NEXT_STATUS_NU_ERR - if more than one next status is possible.
             This error must be circumvented by creating a separate event handler
             which deterministically decides on the next status
   */
  function raise_nil(
    p_req in out nocopy fsm_req_type)
    return binary_integer
  as
  begin
    pit.enter_optional('raise_nil');
    
    -- no implementation required, event shouldn't be fired ever
    p_req.fsm_validity := fsm.C_OK;
    
    pit.leave_optional;
    return p_req.set_status(fsm_fst.fsm_ERROR);
  end raise_nil;
  

  /**
    Group: Interface
   */
  /**
    Procedure: create_fsm_req 
      See <FSM_REQ.create_fsm_req>
   */
  procedure create_fsm_req(
    p_req in out nocopy fsm_req_type,
    p_req_id in fsm_requests.req_id%type default null,
    p_req_fst_id in fsm_status_v.fst_id%type default fsm_fst.REQ_CREATED,
    p_req_fev_list in fsm_events_v.fev_id%type default null,
    p_req_rtp_id in fsm_request_types.rtp_id%type,
    p_req_rre_id in fsm_requestors.rre_id%type,
    p_req_text in fsm_requests.req_text%type)
  as 
  begin
    pit.enter_mandatory;
    
    if p_req_id is null then
      p_req.fsm_fst_id := p_req_fst_id;
      p_req.fsm_fev_list := p_req_fev_list;
      p_req.fsm_fcl_id := C_FCL_ID;
      p_req.req_rtp_id := p_req_rtp_id;
      p_req.req_rre_id := p_req_rre_id;
      p_req.req_text := p_req_text;

      persist(p_req);
      
      pit.verbose(msg.FSM_CREATED, msg_args(C_FCL_ID, to_char(p_req_id)));
      g_result := p_req.set_status(fsm_fst.REQ_CREATED);
    else
      -- Wrong constructor chosen
      create_fsm_req(p_req, p_req_id);
    end if;
    
    pit.leave_mandatory;
  end create_fsm_req;
    

  /**
    Procedure: create_fsm_req 
      See <FSM_REQ.create_fsm_req>
   */
  procedure create_fsm_req(
    p_req in out nocopy fsm_req_type,
    p_req_id in fsm_requests.req_id%type)
  as
    l_req fsm_requests_vw%rowtype;
  begin
    pit.enter_mandatory;
    
    -- Don't call persist in this constructor as it simply loads an existing instance
    -- from table into memory. Persisting would lead to unnecessary log entries only.
    select *
      into l_req
      from fsm_requests_vw
     where req_id = p_req_id;
     
    p_req.fsm_id := l_req.req_id;
    p_req.fsm_fcl_id := l_req.req_fcl_id;
    p_req.fsm_fst_id := l_req.req_fst_id;
    p_req.fsm_fev_list := l_req.req_fev_list;
    p_req.fsm_validity := l_req.req_validity;
    p_req.req_rtp_id := l_req.req_rtp_id;
    p_req.req_rre_id := l_req.req_rre_id;
    p_req.req_text := l_req.req_text;
    
    pit.leave_mandatory;
  exception
    when NO_DATA_FOUND then
      pit.handle_exception;
  end create_fsm_req;
    

  /**
    Procedure: persist_request 
      See <FSM_REQ.persist_request>
   */
  procedure persist_request(
    p_req_id in number, 
	  p_req_rtp_id in varchar2, 
	  p_req_rre_id in varchar2, 
	  p_req_text in varchar2)
  as
    l_req fsm_req_type;
  begin
    l_req := fsm_req_type(
               p_req_id => p_req_id,
               p_req_rtp_id => p_req_rtp_id,
               p_req_rre_id => p_req_rre_id,
               p_req_text => p_req_text);
  end persist_request;
  

  /**
    Function: raise_event 
      See <FSM_REQ.raise_event>
   */
  function raise_event(
    p_req in out nocopy fsm_req_type,
    p_fev_id in fsm_events_v.fev_id%type)
    return binary_integer
  as
  begin
    pit.enter_mandatory;
    
    -- propagate event to super class
    g_result := fsm.raise_event(p_req, p_fev_id);

    -- process event
    if instr(':' || p_req.fsm_fev_list || ':', ':' || p_fev_id || ':') > 0 then
      -- event switch
      case p_fev_id
      -- explicit event handlers
      when fsm_fev.REQ_CHECK then
        g_result := raise_check(p_req);
      when fsm_fev.fsm_NIL then
        g_result := raise_nil(p_req);
      else
        -- default event handler
        g_result := raise_default(p_req, p_fev_id);
      end case;
    else
      pit.warn(msg.fsm_EVENT_NOT_ALLOWED, msg_args(p_fev_id, p_req.fsm_fst_id), p_req.fsm_id);
      g_result := fsm.C_OK;
    end if;
    
    pit.leave_mandatory;
    return g_result;
  end raise_event;
  

  /**
    Procedure: raise_event 
      See <FSM_REQ.raise_event>
   */
  procedure raise_event(
    p_req_id in fsm_objects_v.fsm_id%type,
    p_fev_id in fsm_events_v.fev_id%type)
  as
    l_req fsm_req_type;
    l_result binary_integer;
  begin
    l_req := fsm_req_type(p_req_id);
    l_result := l_req.raise_event(p_req_id);
    pit.assert(l_result = 0);
  end raise_event;
    
    
  /**
    Procedure: set_status 
      See <FSM_REQ.set_status>
   */
  function set_status(
    p_req in out nocopy fsm_req_type)
    return binary_integer
  as
  begin
    pit.enter_mandatory;
    
    persist(p_req);
    
    pit.leave_mandatory;
    return fsm.C_OK;
  exception
    when others then
      pit.handle_exception;
      return fsm.C_ERROR;
  end set_status;

end fsm_req;
/