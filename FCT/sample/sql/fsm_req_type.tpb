create or replace type body &TOOLKIT._req_type
as

  constructor function &TOOLKIT._req_type(
    self in out nocopy &TOOLKIT._req_type,
    p_req_id in number default null,
    p_req_rtp_id in varchar2,
    p_req_rre_id in varchar2,
    p_req_text in varchar2)
    return self as result
  as
  begin
    &TOOLKIT._req_pkg.create_&TOOLKIT._req(
      p_req => self,
      p_req_id => p_req_id,
      p_req_rtp_id => p_req_rtp_id,
      p_req_rre_id => p_req_rre_id,
      p_req_text => p_req_text);
    return;
  end;
  
  constructor function &TOOLKIT._req_type(
    self in out nocopy &TOOLKIT._req_type,
    p_&TOOLKIT._id in number)
    return self as result
  as
  begin
    &TOOLKIT._req_pkg.create_&TOOLKIT._req(
      p_req => self,
      p_req_id => p_&TOOLKIT._id);
    return;
  end;
  
  
  overriding member function raise_event(
    p_fev_id in varchar2)
    return number
  as
    l_result integer;
    l_self &TOOLKIT._req_type := self;
  begin
    -- if &TOOLKIT._pkg.allows_event(l_self, p_fev_id) then
    l_self.&TOOLKIT._validity := &TOOLKIT._req_pkg.raise_event(l_self, p_fev_id);
    if l_self.&TOOLKIT._validity != 0 then
      l_self.retry(p_fev_id);
    end if;
    -- end if;
    return l_result;
  end raise_event;
  
  
  overriding member function set_status(
    p_fst_id in varchar2)
    return number
  as
    l_result integer;
    l_self &TOOLKIT._req_type := self;
  begin
    l_self.&TOOLKIT._fst_id := p_fst_id;
    -- propagate to super class
    l_result := &TOOLKIT._pkg.set_status(l_self);
    -- persist status
    l_result := &TOOLKIT._req_pkg.set_status(l_self);
    -- raise automatic events
    if l_self.&TOOLKIT._auto_raise = &TOOLKIT._pkg.C_TRUE and l_result = &TOOLKIT._pkg.C_OK then
      l_result := l_self.raise_event(l_self.&TOOLKIT._fev_list);
    end if;
    -- call destructor, if next_event_list = 'NIL'
    if l_result = &TOOLKIT._pkg.C_OK and l_self.&TOOLKIT._fev_list = 'NIL' then
      l_self.finalize;
    end if;
    return l_result;
  end set_status;

end;
/