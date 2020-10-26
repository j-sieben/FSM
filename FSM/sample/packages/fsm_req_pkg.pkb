create or replace package body fsm_req_pkg
as

  C_FCL_ID constant varchar2(3 byte) := 'REQ';

  g_result binary_integer;
  
  /* HELPER */
  /* procedure to persist an instance or changes for an instance*/
  procedure persist(
    p_req in fsm_req_type)
  as
  begin
    pit.enter_optional('persist');

    -- propagation to abstract super class
    fsm_pkg.persist(p_req);

    -- merge concrete instance attributes in table fsm_requests by calling its XAPI
    bl_request.merge_request(
      p_req_id => p_req.fsm_id,
      p_req_rtp_id => p_req.req_rtp_id,
      p_req_rre_id => p_req.req_rre_id,
      p_req_text => p_req.req_text);

    commit;

    pit.leave_optional;
  end persist;
  
  
  /* EVENT HANDLER */
  function raise_initialize(
    p_req in out nocopy fsm_req_type)
    return binary_integer
  as
  begin
    pit.enter_optional('raise_initialize');
    
    g_result := fsm_pkg.C_OK;
    -- Logic goes here
    p_req.fsm_validity := g_result;
    
    pit.leave_optional;
    return p_req.set_status(fsm_pkg.get_next_status(p_req, fsm_fev.REQ_INITIALIZE));
  end raise_initialize;
  
  
  function raise_check(
    p_req in out nocopy fsm_req_type)
    return binary_integer
  as
    l_new_status fsm_status.fst_id%type;
    l_mode pls_integer;
  begin
    pit.enter_optional('raise_check');
    
    g_result := fsm_pkg.C_OK;
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
  
  
  function raise_grant(
    p_req in out nocopy fsm_req_type)
    return binary_integer
  as
  begin
    pit.enter_optional('raise_grant');
    
    g_result := fsm_pkg.C_OK;
    -- Logic goes here
    p_req.fsm_validity := g_result;
    
    pit.leave_optional;
    return p_req.set_status(fsm_pkg.get_next_status(p_req, fsm_fev.REQ_GRANT));
  end raise_grant;
  
  
  function raise_reject(
    p_req in out nocopy fsm_req_type)
    return binary_integer
  as
  begin
    pit.enter_optional('raise_reject');
    
    g_result := fsm_pkg.C_OK;
    -- Logic goes here
    p_req.fsm_validity := g_result;
    
    pit.leave_optional;
    return p_req.set_status(fsm_pkg.get_next_status(p_req, fsm_fev.REQ_REJECT));
  end raise_reject;


  function raise_nil(
    p_req in out nocopy fsm_req_type)
    return binary_integer
  as
  begin
    pit.enter_optional('raise_nil');
    
    -- no implementation required, event shouldn't be fired ever
    p_req.fsm_validity := fsm_pkg.C_OK;
    
    pit.leave_optional;
    return p_req.set_status(fsm_fst.fsm_ERROR);
  end raise_nil;
  

  /* INTERFACE */
  procedure create_fsm_req(
    p_req in out nocopy fsm_req_type,
    p_req_id in fsm_requests.req_id%type default null,
    p_req_fst_id in fsm_status.fst_id%type default fsm_fst.REQ_CREATED,
    p_req_fev_list in fsm_event.fev_id%type default null,
    p_req_rtp_id in fsm_request_types.rtp_id%type,
    p_req_rre_id in fsm_requestors.rre_id%type,
    p_req_text in fsm_requests.req_text%type)
  as 
  begin
    pit.enter_mandatory;
    
    if p_req_id is null then
      p_req.fsm_id := fsm_seq.nextval;
      p_req.fsm_fst_id := p_req_fst_id;
      p_req.fsm_fev_list := p_req_fev_list;
      p_req.fsm_fcl_id := C_FCL_ID;
      p_req.req_rtp_id := p_req_rtp_id;
      p_req.req_rre_id := p_req_rre_id;
      p_req.req_text := p_req_text;

      persist(p_req);
      
      pit.verbose(msg.fsm_CREATED, msg_args(C_FCL_ID, to_char(l_req_id)), l_req_id);
      g_result := p_req.set_status(fsm_fst.REQ_CREATED);
    else
      -- Wrong constructor chosen
      create_fsm_req(p_req, p_req_id);
    end if;
    
    pit.leave_mandatory;
  end create_fsm_req;
    

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
     where fsm_id = p_req_id;
     
    p_req.fsm_id := l_req.fsm_id;
    p_req.fsm_fst_id := l_req.fsm_fst_id;
    p_req.fsm_fev_list := l_req.fsm_fev_list;
    p_req.req_rtp_id := l_req.req_rtp_id;
    p_req.req_rre_id := l_req.req_rre_id;
    p_req.req_text := l_req.req_text;
    
    pit.leave_mandatory;
  exception
    when NO_DATA_FOUND then
      pit.sql_exception;
  end create_fsm_req;
    

  function raise_event(
    p_req in out nocopy fsm_req_type,
    p_fev_id in fsm_event.fev_id%type)
    return binary_integer
  as
  begin
    pit.enter_mandatory;
    
    -- propagate event to super class
    g_result := fsm_pkg.raise_event(p_req, p_fev_id);

    -- process event
    if instr(':' || p_req.fsm_fev_list || ':', ':' || p_fev_id || ':') > 0 then
      -- event switch
      case p_fev_id
      when fsm_fev.REQ_INITIALIZE then
        g_result := raise_initialize(p_req);
      when fsm_fev.REQ_CHECK then
        g_result := raise_check(p_req);
      when fsm_fev.REQ_GRANT then
        g_result := raise_grant(p_req);
      when fsm_fev.REQ_REJECT then
        g_result := raise_reject(p_req);
      when fsm_fev.fsm_NIL then
        g_result := raise_nil(p_req);
      else
        pit.warn(msg.fsm_INVALID_EVENT, msg_args(p_fev_id), p_req.fsm_id);
      end case;
    else
      pit.warn(msg.fsm_EVENT_NOT_ALLOWED, msg_args(p_fev_id, p_req.fsm_fst_id), p_req.fsm_id);
      g_result := fsm_pkg.C_OK;
    end if;
    
    pit.leave_mandatory;
    return g_result;
  end raise_event;
    
    
  function set_status(
    p_req in out nocopy fsm_req_type)
    return binary_integer
  as
  begin
    pit.enter_mandatory;
    
    persist(p_req);
    
    pit.leave_mandatory;
    return fsm_pkg.C_OK;
  exception
    when others then
      pit.sql_exception;
      return fsm_pkg.C_ERROR;
  end set_status;

end fsm_req_pkg;
/
