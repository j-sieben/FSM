create or replace package bl_request
  authid definer
as
  
  C_GRANT_AUTOMATICALLY constant pls_integer := 1;
  C_GRANT_MANUALLY constant pls_integer := 2;
  C_GRANT_SUPERVISOR constant pls_integer := 3;
  
  C_TRUE char(1 byte) := 'Y';
  C_FALSE char(1 byte) := 'N';
  
  /** Method to persist a request type
   * @param  p_row  Instance of FSM_REQUEST_TYPES
   * @usage  Is used to persist changes to or create new request types
   */
  procedure merge_request_type(
    p_row in fsm_request_types%rowtype);
    
  procedure merge_request_type(
    rtp_id in varchar2, 
    rtp_name in varchar2, 
    rtp_description in varchar2, 
    rtp_active in varchar2 default C_TRUE);
    
  /** Method to delete a request type
   * @param  p_row  Instance of FSM_REQUEST_TYPES
   * @usage  Is used to delete a request type. Will throw an exception if referenced by requests
   */
  procedure delete_request_type(
    p_row in fsm_request_types%rowtype);
  
  
  /** Method to persist a requestor
   * @param  p_row  Instance of FSM_REQUESTORS
   * @usage  Is used to persist changes to or create new requestors
   */
  procedure merge_requestor(
    p_row in fsm_requestors%rowtype);
    
  procedure merge_requestor(
    rre_id in varchar2, 
    rre_name in varchar2, 
    rre_description in varchar2);
    
  /** Method to delete a requestor
   * @param  p_row  Instance of FSM_REQUESTORS
   * @usage  Is used to delete a requestor. Will throw an exception if referenced by requests
   */
  procedure delete_requestor(
    p_row in fsm_requestors%rowtype);
    

  /** Method to persist a request
   * @param  p_row  Instance of FSM_REQUESTS
   * @usage  Is used to persist changes or create new objects
   */
  procedure merge_request(
    p_row in out nocopy fsm_requests%rowtype);
    
  procedure merge_request(
    p_req_id in out nocopy number, 
	  p_req_rtp_id in varchar2, 
	  p_req_rre_id in varchar2, 
	  p_req_text in varchar2);

  /** Method to delete a request
   * @param  p_row  Instance of FSM_REQUESTS
   * @usage  Is used to delete a request object
   */  
  procedure delete_request(
    p_row in fsm_requests%rowtype);
    
  /** Method to decide on how to grant a right
   * @param  p_rtp_id  Type of the right to be granted
   * @param  p_rre_id  Requestor
   * @return One of the constants C_GRANT_... indicating how to grant a right
   * @usage  Is used to decide whether a right may be granted automatically, needs confirmation or a supervisor account
   */
  function get_grant_mode(
    p_rtp_id in fsm_request_types.rtp_id%type,
    p_rre_id in fsm_requestors.rre_id%type)
    return pls_integer;

end bl_request;
/