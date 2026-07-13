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
    fsm_req.create_fsm_req(
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
    fsm_req.load_fsm_req(
      p_req => self,
      p_fsm_id => p_fsm_id);
    return;
  end;
  
  
  overriding member function raise_event(
    self in out nocopy fsm_req_type,
    p_fev_id in varchar2,
    p_msg in varchar2 default null,
    p_msg_args in msg_args default null)
    return number
  as
    l_result integer;
  begin
    -- if fsm_pkg.allows_event(self, p_fev_id) then
    l_result := fsm_req.raise_event(self, p_fev_id, p_msg, p_msg_args);
    self.fsm_validity := l_result;
    if self.fsm_validity != 0 then
      self.retry(p_fev_id);
      l_result := self.fsm_validity;
    end if;
    -- end if;
    return l_result;
  end raise_event;
  
  
  overriding member procedure persist_state(
    self in out nocopy fsm_req_type)
  as
  begin
    fsm_req.set_status(self);
  end persist_state;

end;
/
