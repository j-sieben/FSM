create or replace package fsm_req
  authid definer
as
  /**
    Package: FSM_REQ
      Package to implement the FSM related logic for requests

    Author::
      Juergen Sieben, ConDeS GmbH

   */

  /**
    Procedure: create_fsm_req
      Is called from FSM_REQ_TYPE constructor function to create a new instance of FSM_REQ_TYPE
      
    Parameters:
      p_req - instance of FSM_REQ_TYPE to be created
      p_req_id - ID of the request
      p_req_fst_id - Status of the request, reference to FSM_STATUS
      p_req_fev_list - List of allowed events
      p_req_rtp_id - type of the request, reference to FSM_REQ_TYPE
      p_req_rre_id - requesting person, rerefence to FSM_requestors
      p_req_text - request text
   */
  procedure create_fsm_req(
    p_req in out nocopy fsm_req_type,
    p_req_id in fsm_requests.req_id%type default null,
    p_req_fst_id in fsm_status_v.fst_id%type default fsm_fst.REQ_CREATED,
    p_req_fev_list in fsm_events_v.fev_id%type default null,
    p_req_rtp_id in fsm_request_types.rtp_id%type,
    p_req_rre_id in fsm_requestors.rre_id%type,
    p_req_text in fsm_requests.req_text%type);
    

  /**
    Procedure: create_fsm_req
      Overlaod to re-create an already persisted instance from FSM_REQUESTS 
   
    Parameters:
      p_req - instance of FSM_REQ_TYPE to be re-created
      p_req_id - ID of the existing request
   */
  procedure create_fsm_req(
    p_req in out nocopy fsm_req_type,
    p_req_id in fsm_requests.req_id%type);
    

  /**
    Function: raise_event
      Method to manually raise an event. This method is called if an event has to be called manually for a
      given instance of FSM_REQ_TYPE. Calling an event can be accomplished
      by calling this method manually, from a button or from a database job fi.
      
    Parameters:
      p_req - instance of type FSM_REQ_TYPE
      p_fev_id - Event to raise. Reference to FSM_EVENT
      
    Returns:
      Status code on whether the event could be raised successfully. One of the constants FSM.C_OK or FSM.C_ERROR or a retry counter value.
   */
  function raise_event(
    p_req in out nocopy fsm_req_type,
    p_fev_id in fsm_events_v.fev_id%type)
    return binary_integer;
    

  /**
    Procedure: set_status
      Method to set a new status. Is called from an event handler that has calculated the new status.
      
    Parameter:
      p_req - instance of type FSM_REQ_TYPE
      
    Returns:
      Status code on whether the event could be raised successfully. One of the constants FSM.C_OK or FSM.C_ERROR or a retry counter value.
   */
  function set_status(
    p_req in out nocopy fsm_req_type)
    return binary_integer;

end fsm_req;
/