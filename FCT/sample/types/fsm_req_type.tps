create or replace type &TOOLKIT._req_type under &TOOLKIT._type(
  req_rtp_id varchar2(50 char),
  req_rre_id varchar2(50 char),
  req_text varchar2(1000 char),
  constructor function &TOOLKIT._req_type(
    self in out nocopy &TOOLKIT._req_type,
    p_req_id in number default null,
    p_req_rtp_id in varchar2,
    p_req_rre_id in varchar2,
    p_req_text in varchar2)
    return self as result,
  constructor function &TOOLKIT._req_type(
    self in out nocopy &TOOLKIT._req_type,
    p_&TOOLKIT._id in number)
    return self as result,
  overriding member function raise_event(
    p_fev_id in varchar2)
    return number,
  overriding member function set_status(
    p_fst_id in varchar2)
    return number
);
/