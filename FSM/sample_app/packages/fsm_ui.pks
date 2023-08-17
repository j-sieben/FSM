create or replace package fsm_ui
  authid definer
as

  /**
    Package: FSM_UI
      Application UI package to host the controler logic

    Author::
      Juergen Sieben, ConDeS GmbH

   */

  /**
    Constants: Public Constants
  */
  
  /**
    Group: UI Methods
   */
  /**
    Procedure: edit_request_process
      Method to handle changes to page EDIT_REQUEST
   */
  procedure edit_request_process;
  
  
  /**
    Procedure: raise_event
      Method to raise an event, passed in as a REQUEST value on the actual REQ_ID
   */
  procedure raise_event;
end;
/