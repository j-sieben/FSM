create or replace package &TOOLKIT._req_pkg
  authid definer
as
  /* Constructor for &TOOLKIT._REQ_TYPE
   * %param p_req instance of &TOOLKIT._REQ_TYPE to be created
   * %param p_req_rtp_id type of the request, reference to &TOOLKIT._REQ_TYPE
   * %param p_req_rre_id requesting person, rerefence to &TOOLKIT._REQ_REQUESTOR
   * %param p_req_text request text
   * %usage procedure is called from &TOOLKIT._REQ_TYPE constructor function
   *        to create a new instance of &TOOLKIT._REQ_TYPE
   */
  procedure create_&TOOLKIT._req(
    p_req in out nocopy &TOOLKIT._req_type,
    p_req_id in number default null,
    p_req_fst_id in varchar2 default &TOOLKIT._fst.REQ_CREATED,
    p_req_fev_list in varchar2 default null,
    p_req_rtp_id in varchar2,
    p_req_rre_id in varchar2,
    p_req_text in varchar2);
    

  /* Overlaod to re-create an already persisted instance from &TOOLKIT._req_OBJECT */
  procedure create_&TOOLKIT._req(
    p_req in out nocopy &TOOLKIT._req_type,
    p_req_id in number);
    

  /* method to manually raise an event.
   * %param p_req instance of type &TOOLKIT._req_TYPE
   * %param p_fev_id event to raise. Refernce to FSM_EVENT
   * %usage This method is called if an event has to be called manually for a
   *        given instance of &TOOLKIT._REQ_TYPE. Calling an event can be accomplished
   *        by calling this method manually, from a button or from a database job fi.
   */
  function raise_event(
    p_req in out nocopy &TOOLKIT._req_type,
    p_fev_id in &TOOLKIT._event.fev_id%type)
    return integer;
    

  /* method to set a new status.
   * %param p_req instance of type &TOOLKIT._REQ_TYPE
   * %usage method is called from an event handler that has calculated the new status.
   */
  function set_status(
    p_req in out nocopy &TOOLKIT._req_type)
    return integer;

end &TOOLKIT._req_pkg;
/