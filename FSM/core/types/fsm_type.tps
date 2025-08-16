create or replace type fsm_type force
authid definer
as object(
  fsm_id number,
  fsm_fcl_id &ORA_NAME_TYPE.,
  fsm_fsc_id &ORA_NAME_TYPE.,
  fsm_fst_id &ORA_NAME_TYPE.,
  fsm_validity number,
  fsm_fev_list varchar2(4000),
  fsm_auto_raise &FLAG_TYPE.,
  member function get_actual_status
    return varchar2,
  member function get_next_event_list
    return varchar2,
  member function get_validity
    return varchar2,
  member function raise_event(
    self in out nocopy fsm_type,
    p_fev_id in varchar2,
    p_msg in varchar2 default null,
    p_msg_args in msg_args default null)
    return number,
  member procedure retry(
    self in out nocopy fsm_type,
    p_fev_id in varchar2),
  member function set_status(
    self in out nocopy fsm_type,
    p_fst_id in varchar2,
    p_msg in varchar2 default null,
    p_msg_args in msg_args default null)
    return number,
  member procedure notify(
    self in out nocopy fsm_type,
    p_msg in varchar2,
    p_msg_args in msg_args default null),
  member function to_string
    return varchar2,
  member procedure finalize(
    self in out nocopy fsm_type)
) not instantiable not final;
/