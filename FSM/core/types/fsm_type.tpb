create or replace type body fsm_type as

  member function raise_event(
    self in out nocopy fsm_type,
    p_fev_id in varchar2)
    return number
  as
  begin
    return fsm.raise_event(self, p_fev_id);
  end raise_event;

  member procedure retry(
    self in out nocopy fsm_type,
    p_fev_id in varchar2)
  as
  begin
    fsm.retry(self, p_fev_id);
  end retry;

  member function get_actual_status
    return varchar2
  as
  begin
    return self.fsm_fst_id;
  end get_actual_status;

  member function get_next_event_list
    return varchar2
  as
  begin
    return self.fsm_fev_list;
  end get_next_event_list;

  member function get_validity
    return varchar2
  as
  begin
    return self.fsm_validity;
  end get_validity;

  member function set_status(
    self in out nocopy fsm_type,
    p_fst_id in varchar2)
    return number
  as
    l_result binary_integer;
  begin
    self.fsm_fst_id := p_fst_id;
    l_result := fsm.set_status(self);
    return l_result;
  end set_status;


  member procedure notify(
    self in out nocopy fsm_type,
    p_msg in varchar2,
    p_msg_args in msg_args default null)
  as
  begin
    fsm.notify(
      p_fsm => self,
      p_msg => p_msg,
      p_msg_args => p_msg_args);
  end notify;

  member function to_string
    return varchar2
  as
  begin
    return fsm.to_string(self);
  end to_string;

  member procedure finalize(
    self in out nocopy fsm_type)
  as
  begin
    fsm.finalize(self);
  end finalize;

end;
/