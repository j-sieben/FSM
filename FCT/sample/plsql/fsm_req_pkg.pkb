create or replace package body &TOOLKIT._req_pkg
as

  c_pkg constant varchar2(30 byte) := $$PLSQL_UNIT;
  c_fcl_id constant varchar2(3 byte) := 'REQ';
  c_ok constant number := 0;
  c_error constant number := 1;
  c_initial_status constant varchar2(50 char) := &TOOLKIT._fst.REQ_CREATED;

  g_result integer;
  g_new_status &TOOLKIT._status.fst_id%type;
  
  /* HELPER */
  /* procedure to persist an instance or changes for an instance*/
  procedure persist(
    p_req in &TOOLKIT._req_type)
  as
  begin
    --pit.enter('persist', c_pkg);

    -- propagation to abstract super class
    &TOOLKIT._pkg.persist(p_req);

    -- merge concreate instance attributes in table &TOOLKIT._REQ_OBJECT
    merge into &TOOLKIT._req_object d
    using (select p_req.&TOOLKIT._id req_id,
                  p_req.req_rtp_id req_rtp_id,
                  p_req.req_rre_id req_rre_id,
                  p_req.req_text req_text
             from dual) v
       on (d.req_id = v.req_id)
     when matched then update set
          req_text = v.req_text
     when not matched then insert (req_id, req_rtp_id, req_rre_id, req_text)
          values(v.req_id, v.req_rtp_id, v.req_rre_id, v.req_text);

    commit;

    --pit.leave;
  end persist;
  
  
  /* EVENT HANDLER */
  function raise_initialize(
    p_req in out nocopy &TOOLKIT._req_type)
    return number
  as
  begin
    --pit.enter('raise_initialize', c_pkg);
    g_result := c_ok;
    -- Logic goes here
    p_req.&TOOLKIT._validity := g_result;
    --pit.leave;
    return p_req.set_status(&TOOLKIT._fst.REQ_IN_PROCESS);
  end raise_initialize;
  
  
  function raise_check(
    p_req in out nocopy &TOOLKIT._req_type)
    return number
  as
    l_new_status &TOOLKIT._status.fst_id%type;
    c_object_priv constant &TOOLKIT._req_types.rtp_id%type := 'OBJECT_PRIV';
    c_system_priv constant &TOOLKIT._req_types.rtp_id%type := 'SYSTEM_PRIV';
  begin
    --pit.enter('raise_check', c_pkg);
    g_result := c_ok;
    -- Logic goes here
    case 
    when p_req.req_rtp_id = c_object_priv and p_req.req_rre_id = 'PATABALLA' then
      l_new_status := &TOOLKIT._fst.REQ_GRANT_AUTOMATICALLY;
    when p_req.req_rtp_id = c_object_priv then
      l_new_status := &TOOLKIT._fst.REQ_GRANT_MANUALLY;
    else
      l_new_status := &TOOLKIT._fst.REQ_GRANT_SUPERVISOR;
    end case;
    
    p_req.&TOOLKIT._validity := g_result;
    --pit.leave;
    return p_req.set_status(l_new_status);
  end raise_check;
  
  
  function raise_grant(
    p_req in out nocopy &TOOLKIT._req_type)
    return number
  as
  begin
    --pit.enter('raise_grant', c_pkg);
    g_result := c_ok;
    -- Logic goes here
    p_req.&TOOLKIT._validity := g_result;
    --pit.leave;
    return p_req.set_status(&TOOLKIT._fst.REQ_GRANTED);
  end raise_grant;
  
  
  function raise_reject(
    p_req in out nocopy &TOOLKIT._req_type)
    return number
  as
  begin
    --pit.enter('raise_reject', c_pkg);
    g_result := c_ok;
    -- Logic goes here
    p_req.&TOOLKIT._validity := g_result;
    --pit.leave;
    return p_req.set_status(&TOOLKIT._fst.REQ_REJECTED);
  end raise_reject;


  function raise_nil(
    p_req in out nocopy &TOOLKIT._req_type)
    return number
  as
  begin
    --pit.enter('raise_nil', c_pkg);
    -- no implementation required, event shouldn't be fired ever
    --pit.leave;
    p_req.&TOOLKIT._validity := c_ok;
    return p_req.set_status(&TOOLKIT._fst.&TOOLKIT._ERROR);
  end raise_nil;
  

  /* INTERFACE */
  procedure create_&TOOLKIT._req(
    p_req in out nocopy &TOOLKIT._req_type,
    p_req_id in number default null,
    p_req_fst_id in varchar2 default &TOOLKIT._fst.REQ_CREATED,
    p_req_fev_list in varchar2 default null,
    p_req_rtp_id in varchar2,
    p_req_rre_id in varchar2,
    p_req_text in varchar2)
  as 
    l_req_id &TOOLKIT._req_object.req_id%type;
  begin
    --pit.enter('create_&TOOLKIT._req', c_pkg);
    l_req_id := coalesce(p_req_id, &TOOLKIT._seq.nextval);

    p_req.&TOOLKIT._id := l_req_id;
    p_req.&TOOLKIT._fst_id := p_req_fst_id;
    p_req.&TOOLKIT._fev_list := p_req_fev_list;
    p_req.&TOOLKIT._fcl_id := c_fcl_id;
    p_req.req_rtp_id := p_req_rtp_id;
    p_req.req_rre_id := p_req_rre_id;
    p_req.req_text := p_req_text;

    if p_req_id is null then
      --pit.verbose(msg.&TOOLKIT._CREATED, msg_args(c_fcl_id, to_char(l_req_id)), l_req_id);
      g_result := p_req.set_status(&TOOLKIT._fst.REQ_CREATED);
    else
      persist(p_req);
    end if;
    
    --pit.leave;
  end create_&TOOLKIT._req;
    

  procedure create_&TOOLKIT._req(
    p_req in out nocopy &TOOLKIT._req_type,
    p_req_id in number)
  as
    l_req &TOOLKIT._req_object_vw%rowtype;
  begin
    select *
      into l_req
      from &TOOLKIT._req_object_vw
     where &TOOLKIT._id = p_req_id;
    create_&TOOLKIT._req(
      p_req => p_req,
      p_req_id => l_req.&TOOLKIT._id,
      p_req_fst_id => l_req.&TOOLKIT._fst_id,
      p_req_fev_list => l_req.&TOOLKIT._fev_list,
      p_req_rtp_id => l_req.req_rtp_id,
      p_req_rre_id => l_req.req_rre_id,
      p_req_text => l_req.req_text);
  end create_&TOOLKIT._req;
    

  function raise_event(
    p_req in out nocopy &TOOLKIT._req_type,
    p_fev_id in &TOOLKIT._event.fev_id%type)
    return integer
  as
  begin
    --pit.enter('raise_event', c_pkg);
    -- propagate event to super class
    g_result := &TOOLKIT._pkg.raise_event(p_req, p_fev_id);

    -- process event
    if instr(':' || p_req.&TOOLKIT._fev_list || ':', ':' || p_fev_id || ':') > 0 then
      -- Eventweiche
      case p_fev_id
      when &TOOLKIT._fev.REQ_INITIALIZE then
        g_result := raise_initialize(p_req);
      when &TOOLKIT._fev.REQ_CHECK then
        g_result := raise_check(p_req);
      when &TOOLKIT._fev.REQ_GRANT then
        g_result := raise_grant(p_req);
      when &TOOLKIT._fev.REQ_REJECT then
        g_result := raise_reject(p_req);
      when &TOOLKIT._fev.&TOOLKIT._NIL then
        g_result := raise_nil(p_req);
      ELSE
          NULL;
        --pit.warn(msg.&TOOLKIT._INVALID_EVENT, msg_args(p_fev_id), p_req.&TOOLKIT._id);
      end case;
    else
      --pit.warn(msg.&TOOLKIT._EVENT_NOT_ALLOWED, msg_args(p_fev_id, p_req.&TOOLKIT._fst_id), p_req.&TOOLKIT._id);
      g_result := c_ok;
    end if;
    --pit.leave;
    return g_result;
  end raise_event;
    
    
  function set_status(
    p_req in out nocopy &TOOLKIT._req_type)
    return integer
  as
  begin
    --pit.enter('set_status', c_pkg);
    persist(p_req);
    --pit.leave;
    return &TOOLKIT._pkg.C_OK;
  exception
    when others then
      return &TOOLKIT._pkg.C_ERROR;
  end set_status;

end &TOOLKIT._req_pkg;
/
