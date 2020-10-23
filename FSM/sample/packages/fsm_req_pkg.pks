create or replace package fsm_req_pkg
  authid definer
as
  /* Constructor for fsm_REQ_TYPE
   * @param p_req          instance of fsm_REQ_TYPE to be created
   * @param p_req_id       ID of the request
   * @param p_req_fst_id   Status of the request, reference to fsm_STATUS
   * @param p_req_fev_list List of allowed events
   * @param p_req_rtp_id   type of the request, reference to fsm_REQ_TYPE
   * @param p_req_rre_id   requesting person, rerefence to fsm_REQ_REQUESTOR
   * @param p_req_text     request text
   * @usage procedure is called from fsm_REQ_TYPE constructor function
   *        to create a new instance of fsm_REQ_TYPE
   */
  procedure create_fsm_req(
    p_req in out nocopy fsm_req_type,
    p_req_id in fsm_req_object.req_id%type default null,
    p_req_fst_id in fsm_status.fst_id%type default fsm_fst.REQ_CREATED,
    p_req_fev_list in fsm_event.fev_id%type default null,
    p_req_rtp_id in fsm_req_types.rtp_id%type,
    p_req_rre_id in fsm_req_requestor.rre_id%type,
    p_req_text in fsm_req_object.req_text%type);
    

  /* Overlaod to re-create an already persisted instance from fsm_req_OBJECT */
  procedure create_fsm_req(
    p_req in out nocopy fsm_req_type,
    p_req_id in fsm_req_object.req_id%type);
    

  /* method to manually raise an event.
   * @param p_req    instance of type fsm_REQ_TYPE
   * @param p_fev_id event to raise. Refernce to fsm_EVENT
   * @usage This method is called if an event has to be called manually for a
   *        given instance of fsm_REQ_TYPE. Calling an event can be accomplished
   *        by calling this method manually, from a button or from a database job fi.
   */
  function raise_event(
    p_req in out nocopy fsm_req_type,
    p_fev_id in fsm_event.fev_id%type)
    return binary_integer;
    

  /* method to set a new status.
   * @param p_req instance of type fsm_REQ_TYPE
   * @usage method is called from an event handler that has calculated the new status.
   */
  function set_status(
    p_req in out nocopy fsm_req_type)
    return binary_integer;

end fsm_req_pkg;
/