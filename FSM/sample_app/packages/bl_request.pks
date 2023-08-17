create or replace package bl_request
  authid definer
as

  /**
    Package: BL_REQUEST
      Business logic package for the request application

    Author::
      Juergen Sieben, ConDeS GmbH

   */

  /**
    Constants: Public Constants
      C_GRANT_AUTOMATICALLY - Requested privilege is granted automatically
      C_GRANT_MANUALLY - Requested privilege must be granted manually
      C_GRANT_SUPERVISOR - Requested privilege must be granted manually by a user with supervisor role
  */
  
  C_GRANT_AUTOMATICALLY constant pls_integer := 1;
  C_GRANT_MANUALLY constant pls_integer := 2;
  C_GRANT_SUPERVISOR constant pls_integer := 3;
  
  /**
    Procedure: merge_request_type
      Method to persist changes to or create new request types
      
    Parameter:
      p_row - Instance of FSM_REQUEST_TYPES_VW
   */
  procedure merge_request_type(
    p_row in fsm_request_types_vw%rowtype);
    
  
  /**
    Procedure: merge_request_type
      Method to persist changes to or create new request types. Overload with explicit parameters
      
    Parameters:
      p_rtp_id - ID of the request type
      p_rtp_name - Display name
      p_rtp_description - Optional description
      p_rtp_active - Flag to indicate whether the request type is in use actually
   */
  procedure merge_request_type(
    p_rtp_id in varchar2, 
    p_rtp_name in varchar2, 
    p_rtp_description in varchar2, 
    p_rtp_active in pit_util.flag_type default pit_util.C_TRUE);
    
    
  /** 
    Procedure: delete_request_type
      Method to delete a request type. Will throw an exception if referenced by requests
      
    Parameter:
      p_row - Instance of FSM_REQUEST_TYPES_VW
   */
  procedure delete_request_type(
    p_row in fsm_request_types_vw%rowtype);
  
  
  /**
    Procedure merge_requestor
      Method to persist changes to or create new requestors
      
    Parameter:
      p_row - Instance of FSM_REQUESTORS_VW
   */
  procedure merge_requestor(
    p_row in fsm_requestors_vw%rowtype);
    
  
  /**
    Procedure: merge_requestor
       Method to persist changes to or create new requestors. Overload with explicit parameters
      
    Parameters:
      p_rre_id - ID of the requestor
      p_rre_name - Display name
      p_rre_description - Optional description
   */
  procedure merge_requestor(
    p_rre_id in varchar2, 
    p_rre_name in varchar2, 
    p_rre_description in varchar2);
    
    
  /**
    Procedure: delete_requetor
      Method to delete a requestor. Will throw an exception if referenced by requests
      
    Parameter:
      p_row - Instance of FSM_REQUESTORS_VW
   */
  procedure delete_requestor(
    p_row in fsm_requestors_vw%rowtype);
    

  /**
    Procedure: merge_request
      Method to persist changes or create new requests
      
    Parameter:
      p_row - Instance of FSM_REQUESTS_VW
   */
  procedure merge_request(
    p_row in out nocopy fsm_requests_vw%rowtype);
    
  
  /**
    Procedure: merge_request
       Method to persist changes to or create new requests. Overload with explicit parameters
      
    Parameters:
      p_req_id - ID of the request
      p_req_rtp_id - Reference to the request type
      p_req_rre_id - Reference to the requestor
      p_req_text - Request in textual form
   */
  procedure merge_request(
    p_req_id in out nocopy number, 
	  p_req_rtp_id in varchar2, 
	  p_req_rre_id in varchar2, 
	  p_req_text in varchar2);    


  /**
    Procedure: delete_request
      Method to delete a request
      
    Parameter:
      p_row - Instance of FSM_REQUESTS_VW
   */  
  procedure delete_request(
    p_row in fsm_requests_vw%rowtype);
    
    
  /**
    Function: get_grant_mode
      Method to decide on how to grant a right. Is used to decide whether a right may be granted automatically, needs confirmation or a supervisor account
      
    Parameters:
      p_rtp_id - Type of the right to be granted
      p_rre_id - Requestor
      
    Returns:
      One of the constants C_GRANT_... indicating how to grant a right
   */
  function get_grant_mode(
    p_rtp_id in fsm_request_types.rtp_id%type,
    p_rre_id in fsm_requestors.rre_id%type)
    return pls_integer;

end bl_request;
/