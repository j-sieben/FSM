create or replace package fsm
  authid definer
as
  /**
    Package: FSM
      Implements core functionality of the Finite State Machine.
      The package contains the implementation of the abstract class
      FSM_TYPE and provides generic functions for logging and administration
      of events and status changes.
      
      It serves as a foundation for concrete FSM classes which implement event
      handlers for the real problem domain. By separating the functionality it is
      assured that all these concrete FSM classes share a common way of logging 
      and traversing through the different states.

    Author::
      Juergen Sieben, ConDeS GmbH

      Published under MIT licence
   */

  /**
    Group: Public Types
   */
   /**
    Types: PL/SQL subtypes
      ora_name_type - Oracle name type, length depends on database version: since 12c: 128 byte.
      flag_type - Boolean type for SQL usage. May be obsolete once version 23c can be assumed.
      max_char - Maximum varchar2 PL/SQL variable width
      max_sql_char - Maximum varchar2 SQL width
   */
  subtype max_char is varchar2(32767 byte);
  subtype max_sql_char is varchar2(4000 byte);
  

  /**
    Group: Public Constants
   */
  /**
    Constants:
      C_OK - Flag to indicate that a state transition was successful
      C_ERROR - Flag to indicate that a state transition was unsuccessful
      C_CR - Carriage return character
   */
  C_OK constant binary_integer := 0;
  C_ERROR constant binary_integer := 1;
  C_CR constant varchar2(2 byte) := chr(10);
  

  /**
    Group: Object maintenance
   */
  /**
    Procedure: drop_object
      Method to remove an existing FSM object
      
    Parameter:
      p_fsm_id - ID of the FSM object to drop
   */
  procedure drop_object(
    p_fsm_id in fsm_objects_v.fsm_id%type);


  /**
    Group: FSM_TYPE method implementations
   */
  /**
    Function: raise_event
      On an abstract level this methods only task is to take care of logging.
      Is called by the corresponding function of type FSM_TYPE.
      
    Parameters:
      p_fsm - Instance of the class FSM_TYPE
      p_fev_id - Event that was triggered
      
    Returns:
      C_OK or C_ERROR. C_ERROR only if no logging is performed
   */
  function raise_event(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events_v.fev_id%type)
    return integer;


  /**
    Procedure: persist
      Method persists FSM_TYPE attributes of a concrete derived class in FSM_OBJECT.
      Called by the constructors of the derived classes to to create an entry in FSM_OBJECT. 
      If available, attributes are updated, otherwise the class is created again.
   
    Parameter:
      p_fsm - FSM_TYPE instance
   */
  procedure persist(
    p_fsm in out nocopy fsm_type);


  /**
    Procedure: retry
      Method called when an event produces an error.
      It checks if the event can be executed again (possibly based on a schedule)
      If positive, it throws the event again. If not, the FSM is set to status ERROR.
      
    Parameters:
      p_fsm - FSM_TYPE instance
      p_fev_id - Event that has received an error.
   */
  procedure retry(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events_v.fev_id%type);


  /**
    Function: allows_event
      Method checks if an fsm allows an event to be searched for.
      Called by APEX application to check whether a control should be displayed or executed
      
    Parameters:
      p_fsm - fsm instance
      p_fev_id - Event that is checked
      
    Returns:
      Flag which indicates whether the searched event is allowed (TRUE) or not (FALSE) 
   */
  function allows_event(
    p_fsm in out nocopy fsm_type,
    p_fev_id fsm_events_v.fev_id%type)
    return boolean;


  /**
    Function: set_status
      Method sets the status of an FSM instance. Overloaded as procedure.
      A new status is determined by the logic of the event handler or by calling GET_NEXT_STATUS.
      Based on the new status, allowed events are determined.
      If the following event is automatic, it will be triggered immediately,
      otherwise FSM waits for the event to be triggered externally.
      The procedure overload sets validity at the FSM instance attribute only.
      
    Parameter:
      p_fsm - Instance of fsm (concrete class of the type inherited from FSM_TYPE)
  
    Returns:
      Success state.
      
        C_OK - Normal execution
        C_ERROR - Error
        Integer > 1 - In case of error this indicates the amount of allowed repetitions.
                      Is decreased by 1 for each repetition, until C_ERROR
   */
  function set_status(
    p_fsm in out nocopy fsm_type)
    return number;

  /**
    Procedure: set_status
      Procedure overload
      See <FSM.set_status>
   */
  procedure set_status(
    p_fsm in out nocopy fsm_type);


  /**
    Function: get_next_status
      Method to determine the next possible status. Is called to determine the next state based on the transitions given. 
      If there is no next state, an error is thrown, because this is caused by a wrong parameterization.
      A call is only possible if there is at most one transition to one next state. 
      If more than one status can be reached, the status must be determined by logic and set directly.
      
    Parameters:
      p_fsm - Instance of type FSM_TYPE
      p_fev_id - Event that was raised
      
    Returns:
      Name of the next status
   */
  function get_next_status(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events_v.fev_id%type)
    return varchar2;


  /**
    Procedure: notify
      Method saves a note to an fsm instance. The procedure is called during processing to add annotations.
      
    Parameters:
      p_fsm - Instance of FSM_TYPE to which a note is to be saved
      p_msg - Reference to MSG, will be created as message
      p_msg_args - MSG_ARGS instance
   */
  procedure notify(
    p_fsm in out nocopy fsm_type,
    p_msg in pit_util.ora_name_type,
    p_msg_args in msg_args);


  /**
    Function: to_string
      Method to convert the object into a string. Is used to get an overview of the class attributes.
      
    Parameter:
      p_fsm - FSM-instance to be converted
      
    Returns:
      String with the relevant class attributes
   */
  function to_string(
    p_fsm in fsm_type)
    return varchar2;


  /**
    Procedure: finalize
      "Destructor", cleans up the object
   */
  procedure finalize(
    p_fsm in fsm_type);

end fsm;
/