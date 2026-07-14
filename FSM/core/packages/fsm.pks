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
    Group: Public Constants
   */
  /**
    Constants:
      C_OK - Flag to indicate that a state transition was successful
      C_ERROR - Flag to indicate that a state transition was unsuccessful
      C_CR - Carriage return character
      
      C_STORY_ERROR - Reserved for erroneous outcome to filter error states
      C_STORY_TERMINAL - Final state of a flow
      C_STORY_MILESTONE - Important intermediate target of a flow
      C_STORY_RESULT - Outcome of a flow step
      C_STORY_STEP - Flow step
      C_STORY_TRANSITION - Status movement of a flow step
      C_STORY_DETAIL - Other messages such as progress of a flow step etc.
   */
  C_OK constant binary_integer := 0;
  C_ERROR constant binary_integer := 1;
  C_CR constant varchar2(2 byte) := chr(10);
  
  C_STORY_ERROR constant binary_integer := 10;
  C_STORY_TERMINAL constant binary_integer := 20;
  C_STORY_MILESTONE constant binary_integer := 30;
  C_STORY_RESULT constant binary_integer := 40;
  C_STORY_STEP constant binary_integer := 50;
  C_STORY_TRANSITION constant binary_integer := 60;
  C_STORY_DETAIL constant binary_integer := 70;

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
    Procedure: initialize
      Initializes a new FSM instance and enters the initial status defined by
      the metadata for its class and subclass. The regular status lifecycle
      persists the instance, writes its log entry and processes automatic
      follow-up events before this procedure returns.

      The caller assigns the class, subclass and all subtype-specific attributes
      required by PERSIST_STATE before calling this procedure.

    Parameter:
      p_fsm - New FSM instance to initialize
      p_msg_id - Optional ID of an initialization message
      p_msg_args - Optional message args for the initial message
   */
  procedure initialize(
    p_fsm in out nocopy fsm_type,
    p_msg in pit_util.ora_name_type default null,
    p_msg_args in msg_args default null);


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
      p_msg - Reference to MSG, will be created as message
      p_msg_args - Optional parameters to pass to the log message
      
    Returns:
      C_OK or C_ERROR. C_ERROR only if no logging is performed
   */
  function raise_event(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events_v.fev_id%type,
    p_msg in pit_util.ora_name_type default null,
    p_msg_args in msg_args default null)
    return integer;
    
    
  /**
    Procedure: lock_fsm
      Method implements pessimistic locking for a given FSM instance. If called,
      FSM locks the FSM instance for update. This lock is released after having
      written using the persist method or upon rollback
      
    Parameter:
      p_fsm_id - FSM ID
   */
  procedure lock_fsm(
    p_fsm_id in out nocopy fsm_objects.fsm_id%type);


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
    Procedure: log_reason
      Stores a transient runtime reason for the next successful status log entry.
      If the reason code does not start with <FSM class>_REASON_, this prefix is added.

    Parameters:
      p_fsm - FSM instance
      p_reason_code - Reason code with or without class prefix
      p_msg_args - Optional parameters to pass to the reason message
   */
  procedure log_reason(
    p_fsm in out nocopy fsm_type,
    p_reason_code in pit_util.ora_name_type,
    p_msg_args in msg_args default null);


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
      The transition is processed synchronously in the following order:

      1. Store the previous status and assign the target status.
      2. Call FSM_TYPE.leave_status if an existing status is left.
      3. Call FSM_TYPE.before_transition.
      4. Determine the allowed next events and whether an event is automatic.
      5. Persist the common FSM attributes, then call FSM_TYPE.persist_state for
         subtype-specific persistence.
      6. Write the status log entry.
      7. Call FSM_TYPE.enter_status if the status changed, followed by
         FSM_TYPE.after_transition.
      8. Notify observers about the allowed next events.
      9. Raise an automatic event synchronously. The resulting status change
         repeats this sequence recursively. If no automatic event remains, a
         terminal instance is finalized.
      10. Clear the transition context and commit before returning.

      Consequently, an initial status assigned by a concrete constructor is
      fully processed, including all automatic follow-up events, before the
      constructed instance is returned to its caller. If no event is automatic,
      FSM waits for an event to be triggered externally.
      The procedure overload executes the same lifecycle but discards the
      numeric return value; the resulting validity remains available on the FSM
      instance.
      
    Parameters:
      p_fsm - Instance of fsm (concrete class of the type inherited from FSM_TYPE)
      p_fst_id - Target status of the transition
      p_msg - Reference to MSG, will be created as message
      p_msg_args - Optional parameters to pass to the log message
  
    Returns:
      Success state.
      
        C_OK - Normal execution
        C_ERROR - Error
        Integer > 1 - In case of error this indicates the amount of allowed repetitions.
                      Is decreased by 1 for each repetition, until C_ERROR
   */
  function set_status(
    p_fsm in out nocopy fsm_type,
    p_fst_id in fsm_status_v.fst_id%type,
    p_msg in pit_util.ora_name_type default null,
    p_msg_args in msg_args default null)
    return number;

  /**
    Procedure: set_status
      Overload as procedure. Is used to set the status directly and not as a 
      consequence of an event raised.
      
    Parameters:
      p_fsm - Instance of fsm (concrete class of the type inherited from FSM_TYPE)
      p_fst_id - Target status of the transition
      p_msg - Reference to MSG, will be created as message
      p_msg_args - Optional parameters to pass to the log message
   */
  procedure set_status(
    p_fsm in out nocopy fsm_type,
    p_fst_id in fsm_status_v.fst_id%type,
    p_msg in pit_util.ora_name_type default null,
    p_msg_args in msg_args default null);


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
      p_msg_args - Optional parameters to pass to the log message
   */
  procedure notify(
    p_fsm in out nocopy fsm_type,
    p_msg in pit_util.ora_name_type,
    p_msg_args in msg_args default null);


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
    Function: is_terminal_status
      Evaluates wether the given FSM instance has reached a status that is marked as terminating.

    Parameters:
      p_fsm - FSM instance to check

    Returns:
      True if the FSM has reached a terminating status, FALSE otherwise.
   */
  function is_terminal_status(
    p_fsm in out nocopy fsm_type)
    return boolean;


  /**
    Function: get_escalation_state
      Evaluates the configured duration thresholds for the current status of an FSM instance.

    Parameters:
      p_fsm_id - ID of the FSM instance

    Returns:
      One of OK, WARN or ALERT depending on the configured thresholds.
   */
  function get_escalation_state(
    p_fsm_id in fsm_objects.fsm_id%type)
    return varchar2;


  /**
    Function: get_escalation_reference_date
      Returns the timestamp used as the baseline for escalation evaluation.

    Parameters:
      p_fsm_id - ID of the FSM instance

    Returns:
      Date of the last status change or the last activity, depending on the status configuration.
   */
  function get_escalation_reference_date(
    p_fsm_id in fsm_objects.fsm_id%type)
    return date;


  /**
    Procedure: finalize
      "Destructor", cleans up the object
   */
  procedure finalize(
    p_fsm in fsm_type);

end fsm;
/
