create or replace package &TOOLKIT._req_pkg
  authid definer
as
  /* Constructor for &TOOLKIT._REQ_TYPE
   * %param p_req          instance of &TOOLKIT._REQ_TYPE to be created
   * %param p_req_id       ID of the request
   * %param p_req_fst_id   Status of the request, reference to &TOOLKIT._STATUS
   * %param p_req_fev_list List of allowed events
   * %param p_req_rtp_id   type of the request, reference to &TOOLKIT._REQ_TYPE
   * %param p_req_rre_id   requesting person, rerefence to &TOOLKIT._REQ_REQUESTOR
   * %param p_req_text     request text
   * %usage procedure is called from &TOOLKIT._REQ_TYPE constructor function
   *        to create a new instance of &TOOLKIT._REQ_TYPE
   */
  procedure create_&TOOLKIT._req(
    p_req in out nocopy &TOOLKIT._req_type,
    p_req_id in &TOOLKIT._req_object.req_id%type default null,
    p_req_fst_id in &TOOLKIT._status.fst_id%type default &TOOLKIT._fst.REQ_CREATED,
    p_req_fev_list in &TOOLKIT._event.fev_id%type default null,
    p_req_rtp_id in &TOOLKIT._req_types.rtp_id%type,
    p_req_rre_id in &TOOLKIT._req_requestor.rre_id%type,
    p_req_text in &TOOLKIT._req_object.req_text%type);
    

  /* Overlaod to re-create an already persisted instance from &TOOLKIT._req_OBJECT */
  procedure create_&TOOLKIT._req(
    p_req in out nocopy &TOOLKIT._req_type,
    p_req_id in &TOOLKIT._req_object.req_id%type);
    

  /* method to manually raise an event.
   * %param p_req    instance of type &TOOLKIT._REQ_TYPE
   * %param p_fev_id event to raise. Refernce to &TOOLKIT._EVENT
   * %usage This method is called if an event has to be called manually for a
   *        given instance of &TOOLKIT._REQ_TYPE. Calling an event can be accomplished
   *        by calling this method manually, from a button or from a database job fi.
   */
  function raise_event(
    p_req in out nocopy &TOOLKIT._req_type,
    p_fev_id in &TOOLKIT._event.fev_id%type)
    return binary_integer;
    

  /* method to set a new status.
   * %param p_req instance of type &TOOLKIT._REQ_TYPE
   * %usage method is called from an event handler that has calculated the new status.
   */
  function set_status(
    p_req in out nocopy &TOOLKIT._req_type)
    return binary_integer;

end &TOOLKIT._req_pkg;
/