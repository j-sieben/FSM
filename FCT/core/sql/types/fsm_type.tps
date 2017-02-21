create or replace type &TOOLKIT._type
authid definer
as object(
  &TOOLKIT._id number,
  &TOOLKIT._fcl_id varchar2(50 char),
  &TOOLKIT._fst_id varchar2(50 char),
  &TOOLKIT._validity number,
  &TOOLKIT._fev_list varchar2(4000),
  &TOOLKIT._auto_raise char(1 byte),
  member function get_actual_status
    return varchar2,
  member function get_next_event_list
    return varchar2,
  member function get_validity
    return varchar2,
  member function raise_event(
    p_fev_id in varchar2)
    return number,
  member procedure retry(
    p_fev_id in varchar2),
  member function set_status(
    p_fst_id in varchar2)
    return number,
  member procedure notify(
    p_msg in varchar2/*,
    p_msg_args in msg_args default null*/),
  member function to_string
    return varchar2,
  member procedure finalize
) not instantiable not final;
/
