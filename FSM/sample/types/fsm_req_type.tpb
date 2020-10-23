create or replace type body fsm_req_type
as

  constructor function fsm_req_type(
    self in out nocopy fsm_req_type,
    p_req_id in number default null,
    p_req_rtp_id in varchar2,
    p_req_rre_id in varchar2,
    p_req_text in varchar2)
    return self as result
  as
  begin
    fsm_req_pkg.create_fsm_req(
      p_req => self,
      p_req_id => p_req_id,
      p_req_rtp_id => p_req_rtp_id,
      p_req_rre_id => p_req_rre_id,
      p_req_text => p_req_text);
    return;
  end;
  
  constructor function fsm_req_type(
    self in out nocopy fsm_req_type,
    p_fsm_id in number)
    return self as result
  as
  begin
    fsm_req_pkg.create_fsm_req(
      p_req => self,
      p_req_id => p_fsm_id);
    return;
  end;
  
  
  overriding member function raise_event(
    self in out nocopy fsm_req_type,
    p_fev_id in varchar2)
    return number
  as
    l_result integer;
  begin
    -- if fsm_pkg.allows_event(self, p_fev_id) then
    self.fsm_validity := fsm_req_pkg.raise_event(self, p_fev_id);
    if self.fsm_validity != 0 then
      self.retry(p_fev_id);
    end if;
    -- end if;
    return l_result;
  end raise_event;
  
  
  overriding member function set_status(
    self in out nocopy fsm_req_type,
    p_fst_id in varchar2)
    return number
  as
    l_result integer;
  begin
    self.fsm_fst_id := p_fst_id;
    -- propagate to super class
    l_result := fsm_pkg.set_status(self);
    -- persist status
    l_result := fsm_req_pkg.set_status(self);
    -- raise automatic events
    if self.fsm_auto_raise = util_fsm.C_TRUE and l_result = util_fsm.C_OK then
      l_result := self.raise_event(self.fsm_fev_list);
    end if;
    -- call destructor, if next_event_list = 'NIL'
    if l_result = util_fsm.C_OK and self.fsm_fev_list = 'NIL' then
      self.finalize;
    end if;
    return l_result;
  end set_status;

end;
/