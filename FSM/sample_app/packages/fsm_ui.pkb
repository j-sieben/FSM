create or replace package body fsm_ui
as

  /**
    Package: FSM_UI Body
      Application UI package to host the controler logic

    Author::
      Juergen Sieben, ConDeS GmbH

   */ 
  /**
    Group: Internal Helper Methods
   */
  
  
  /**
    Group: Interface
   */
  /**
    Procedure: edit_request_process
      See <FSM_UI.edit_request_process>
   */
  procedure edit_request_process
  as
  begin
    pit.enter_mandatory;
    
    if utl_apex.inserting or utl_apex.updating then
      fsm_req.persist_request(
        p_req_id => utl_apex.get_number('req_id'),
        p_req_rtp_id => utl_apex.get_string('req_rtp_id'),
        p_req_rre_id => utl_apex.get_string('req_rre_id'),
        p_req_text => utl_apex.get_string('req_text'));
    else
      null; -- not implemented yet
    end if;
    pit.leave_mandatory;
  end edit_request_process;
  
  
  /**
    Procedure: raise_event
      See <FSM_UI.raise_event>
   */
  procedure raise_event
  as
    l_req fsm_req_type;
    l_req_id fsm_requests_vw.req_id%type;
    l_req_fev_id fsm_requests_vw.req_fev_id%type;
    l_result binary_integer;
  begin
    pit.enter_mandatory;
    
    l_req_id := utl_apex.get_number('req_id');
    l_req_fev_id := utl_apex.get_request;
    l_req := fsm_req_type(l_req_id);
    
    l_result := fsm_req.raise_event(
      p_req => l_req,
      p_fev_id => l_req_fev_id);
    
    pit.leave_mandatory;
  end raise_event;
  
end;
/