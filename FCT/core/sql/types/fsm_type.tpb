create or replace type body &TOOLKIT._type as

  member function raise_event(
    p_fev_id in varchar2)
    return number
  as
    l_self &TOOLKIT._type := self;
  begin
    return &TOOLKIT._pkg.raise_event(l_self, p_fev_id);
  end raise_event;

  member procedure retry(
    p_fev_id in varchar2)
  as
  begin
    &TOOLKIT._pkg.retry(self, p_fev_id);
  end retry;

  member function get_actual_status
    return varchar2
  as
  begin
    return self.&TOOLKIT._fst_id;
  end get_actual_status;

  member function get_next_event_list
    return varchar2
  as
  begin
    return self.&TOOLKIT._fev_list;
  end get_next_event_list;

  member function get_validity
    return varchar2
  as
  begin
    return self.&TOOLKIT._validity;
  end get_validity;

  member function set_status(
    p_fst_id in varchar2)
    return number
  as
    l_self &TOOLKIT._type := self;
    l_result binary_integer;
  begin
    l_self.&TOOLKIT._fst_id := p_fst_id;
    l_result := &TOOLKIT._pkg.set_status(l_self);
    return l_result;
  end set_status;


  member procedure notify(
    p_msg in varchar2,
    p_msg_args in msg_args default null)
  as
  begin
    &TOOLKIT._pkg.notify(
      p_&TOOLKIT. => self,
      p_msg => p_msg,
      p_msg_args => p_msg_args);
  end notify;

  member function to_string
    return varchar2
  as
  begin
    return &TOOLKIT._pkg.to_string(self);
  end to_string;

  member procedure finalize
  as
  begin
    &TOOLKIT._pkg.finalize(self);
  end finalize;

end;
/