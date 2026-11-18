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
    l_result := fsm_req.raise_event(self, p_fev_id, p_msg, p_msg_args);
    self.fsm_validity := l_result;
    return l_result;
  end raise_event;
  
  
  /*
    Procedure: refresh_state
      See: <FSM_TYPE.refresh_state>
      Reloads request payload under the common FSM row lock using the technical
      state contract, without translated views or writes.
   */
  overriding member procedure refresh_state(self in out nocopy fsm_req_type) as
  begin
    select req_id, req_rtp_id, req_rre_id, req_text
      into self.req_id, self.req_rtp_id, self.req_rre_id, self.req_text
      from fsm_requests where req_fsm_id = self.fsm_id;
  end refresh_state;

  overriding member procedure persist_state(
    self in out nocopy fsm_req_type)
  as
  begin
    fsm_req.set_status(self);
  end persist_state;

end;
/
