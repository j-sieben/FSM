create or replace package fsm
  authid definer
as
  /* Package for generic management of a Finite State Machine (FSM)
   * @usage: The package contains the implementation of the abstract class
   *         FSM_TYPE and provides generic functions for logging, administration
   *         of events and status changes.
   */

  subtype ora_name_type is &ORA_NAME_TYPE.;
  subtype flag_type is &FLAG_TYPE.;
  subtype max_char is varchar2(32767 byte);
  subtype max_sql_char is varchar2(4000 byte);
  
  /* Package constants for use in derived FSM instances */
  C_OK constant binary_integer := 0;
  C_ERROR constant binary_integer := 1;
  C_TRUE constant flag_type := &C_TRUE.;
  C_FALSE constant flag_type := &C_FALSE.;
  C_CR constant varchar2(2 byte) := chr(10);

  /* On an abstract level this methods only task is to take care of logging.
   * @param  p_fsm     Instance of the class FSM_TYPE
   * @param  p_fev_id  Event that was triggered
   * @return C_OK or C_ERROR. C_ERROR only if no logging is performed
   * @usage  Is called by the corresponding function of type FSM_TYPE.
   */
  function raise_event(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events.fev_id%type)
    return integer;


  /* Method persists FSM_TYPE attributes of a concrete derived class in FSM_OBJECT
   * @param  p_fsm  FSM_TYPE instance
   * @usage  Called by the constructors of the derived classes to to create an entry in FSM_OBJECT. 
   *         If available, attributes are updated, otherwise the class is created again.
   */
  procedure persist(
    p_fsm in fsm_type);


  /* Method called when an event produces an error.
   * @param p_fsm     FSM_TYPE instance
   * @param p_fev_id  Event that has received an error.
   * @usage Called when an event handler throws an error.
   *        It checks if the event can be executed again (possibly based on a schedule)
   *        If positive, it throws the event again. If not, the FSM is set to status ERROR.
   */
  procedure retry(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events.fev_id%type);


  /* Method checks if an fsm allows an event to be searched for.
   * @param  p_fsm     fsm instance
   * @param  p_fev_id  Event that is checked
   * @return Flag, which indicates whether the searched event is allowed (TRUE) or not (FALSE)
   * @usage  Called by APEX application to check whether a control should be displayed or executed
   */
  function allows_event(
    p_fsm in out nocopy fsm_type,
    p_fev_id fsm_events.fev_id%type)
    return boolean;


  /* Method sets the status of an FSM instance. Overloaded as procedure.
   * @param  p_fsm  Instance of fsm (concrete class of the type inherited from FSM_TYPE)
   * @return Success state. 
   *         C_OK: Normal execution
   *         C_ERROR: Error
   *         Integer > 1: In case of error this indicates the amount of allowed repetitions.
   *                      Is decreased by 1 for each repetition, until C_ERROR
   * @usage  A new status is determined by the logic of the event handler or by calling GET_NEXT_STATUS.
   *         Based on the new status, allowed events are determined.
   *         If the following event is automatic, it will be triggered immediately,
   *         otherwise FSM waits for the event to be triggered externally.
   *         The procedure overload sets validity at the FSM instance attribute only.
   */
  function set_status(
    p_fsm in out nocopy fsm_type)
    return number;

  procedure set_status(
    p_fsm in out nocopy fsm_type);


  /* Method to determine the next possible status
   * @param  p_fsm     Instance of type FSM_TYPE
   * @param  p_fev_id  Event that was raised
   * @return Name of the next status
   * @usage  The function is called to determine the next state based on the transitions given. 
   *         If there is no next state, an error is thrown, because this is caused by a wrong parameterization.
   *         A call is only possible if there is at most one transition to one next state. 
   *         If more than one status can be reached, the status must be determined by logic and set directly.
   */
  function get_next_status(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events.fev_id%type)
    return varchar2;


  /* Method saves a note to an fsm instance
   * @param  p_fsm       Instance of FSM_TYPE to which a note is to be saved
   * @param  p_msg       Reference to MSG, will be created as message
   * @param  p_msg_args  MSG_ARGS instance
   * @usage  The procedure is called during processing to add annotations to save for editing
   */
  procedure notify(
    p_fsm in out nocopy fsm_type,
    p_msg in ora_name_type,
    p_msg_args in msg_args);


  /* Method to convert the object into a string
   * @param  p_fsm  Instance to be converted
   * @return string with the relevant class attributes
   * @usage  Is used to get an overview of the class attributes.
   */
  function to_string(
    p_fsm in fsm_type)
    return varchar2;


  /* "Destructor", cleans up the object
   */
  procedure finalize(
    p_fsm in fsm_type);

end fsm;
/