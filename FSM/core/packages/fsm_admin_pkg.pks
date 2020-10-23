create or replace package fsm_admin_pkg
  authid definer 
as
  
  /** Creates or modifies a class
   * @param  p_fcl_id           ID of the class
   * @param  p_fcl_name         Plain text identifier of the class
   * @param  p_fcl_description  Description of the class
   * @param [p_fcl_active]      Flag indicating whether the class should be used (TRUE) or not (FALSE)
   * @usage  Used to create or maintain a class.
   */
  procedure merge_class(
    p_fcl_id in fsm_class.fcl_id%type,
    p_fcl_name in fsm_class.fcl_name%type,
    p_fcl_description in fsm_class.fcl_description%type,
    p_fcl_active in boolean default true);
    
  
  /** Deletes a class.
   * @param  p_fcl_id  ID of the class
   * @param [p_force]  Flag indicating whether all referenced objects should also be deleted (TRUE)
   *                   or not. Default: FALSE
   * @usage  Used to remove a class and optionally all its associated events, states and transitions
   */
  procedure delete_class(
    p_fcl_id in fsm_class.fcl_id%type,
    p_force in boolean default false);
       
  
  /** Creates or modifies a status group
   * @param  p_fsg_id           ID of the status group
   * @param  p_fsg_name         Display name of the status group
   * @param  p_fsg_description  Description of the status group. May be used in tooltips
   * @param [p_fsg_icon_css]    Optional CSS-class to decorate status group with an icon
   * @param [p_fsg_name_css]    Optional CSS-class to decorate status group name
   * @param [p_fst_active]      Flag to indicate whether this status group is actually used or not
   * @usage  Is used to maintain status group meta data at table FSM_STATUS_GROUP.
   */
  procedure merge_status_group(
    p_fsg_id in fsm_status_group.fsg_id%type,
    p_fsg_name in fsm_status_group.fsg_name%type,
    p_fsg_description in fsm_status_group.fsg_description%type,
    p_fsg_icon_css in fsm_status_group.fsg_icon_css%type default null,
    p_fsg_name_css in fsm_status_group.fsg_name_css%type default null,
    p_fsg_active in boolean default true);
    
    
  /** Deletes a status group
   * @param  p_fsg_id  ID of the status group
   * @param [p_force]  Flag indicating whether all pending statuses and their transitions should also be deleted (TRUE)
   *                   or not. Default: FALSE
   * @usage Used to remove a state and optionally all pending states and transitions
   */
  procedure delete_status_group(
    p_fsg_id in fsm_status.fst_id%type,
    p_force in boolean default false);
    
  
  /** Creates or modifies a status
   * @param  p_fst_id                 ID of the status
   * @param  p_fst_fcl_id             Reference to the class the status belongs to
   * @param  p_fst_fsg_id             Reference to a status group
   * @param  p_fst_name               Display name of the status
   * @param  p_fev_description        Description of the status. May be used in tooltips
   * @param [p_fst_msg_id]            Name of the message used for logging
   * @param [p_fst_retries_on_error]  Number of retries allowed to enter this status
   * @param [p_fst_retry_schedule]    Optional schedule if a retry is executed. Controls when this retry takes place
   * @param [p_fst_retry_time]        Optional duration in seconds the retry is hold back
   * @param [p_fst_icon_css]          Optional CSS-class to decorate status with an icon
   * @param [p_fst_name_css]          Optional CSS-class to decorate status name
   * @param [p_fst_active]            Flag to indicate whether this event is used (TRUE) or not (FALSE)
   * @usage  Is used to maintain event meta data at table FSM_EVENT.
   */
  procedure merge_status(
    p_fst_id in fsm_status.fst_id%type,
    p_fst_fcl_id in fsm_status.fst_fcl_id%type,
    p_fst_fsg_id in fsm_status.fst_fsg_id%type,
    p_fst_name in fsm_status.fst_name%type,
    p_fst_description in fsm_status.fst_description%type,
    p_fst_msg_id in fsm_status.fst_msg_id%type default msg.FSM_STATUS_CHANGED,
    p_fst_retries_on_error in fsm_status.fst_retries_on_error%type default 0,
    p_fst_retry_schedule in fsm_status.fst_retry_schedule%type default null,
    p_fst_retry_time in fsm_status.fst_retry_time%type default null,
    p_fst_icon_css in fsm_status.fst_icon_css%type default null,
    p_fst_name_css in fsm_status.fst_name_css%type default null,
    p_fst_active in boolean default true);
    
    
  /** Deletes a status
   * @param  p_fst_id  ID of the status
   * @param [p_force]  Flag indicating whether all pending transitions should also be deleted (TRUE)
   *                   or not. Default: FALSE
   * @usage Used to remove a state and optionally all pending transitions
   */
  procedure delete_status(
    p_fst_id in fsm_status.fst_id%type,
    p_force in boolean default false);
    
    
  /** Creates or modifies an event
   * @param  p_fev_id                ID of the event
   * @param  p_fev_fcl_id            Reference to the class the event belongs to
   * @param  p_fev_name              Display name of the event
   * @param  p_fev_description       Description of the event. May be used in tooltips
   * @param [p_fev_msg_id]           Name of the message used for logging
   * @param [p_fev_raised_by_user]   Flag to indicate whether this event has to be raised by human interaction
   * @param [p_fev_command]          Optional name of a command.
   * @param [p_fev_button_icon]      Optional icon for a command button
   * @param [p_fev_button_highlight] Optional flag to indicate whether this is a default option
   * @param [p_fev_confirm_message]  Optiona message that is shown as a confirmation message before executing the command
   * @param [p_fev_active]           Flag to indicate whether this event is used (TRUE) or not (FALSE)
   * @usage  Is used to maintain event meta data at table FSM_EVENT.
   */
  procedure merge_event(
    p_fev_id in fsm_event.fev_id%type,
    p_fev_fcl_id in fsm_event.fev_fcl_id%type,
    p_fev_name in fsm_event.fev_name%type,
    p_fev_description in fsm_event.fev_description%type,
    p_fev_msg_id in fsm_event.fev_msg_id%type default msg.FSM_EVENT_RAISED,
    p_fev_raised_by_user in boolean default false,
    p_fev_command in fsm_event.fev_command%type default null,
    p_fev_button_icon in fsm_event.fev_button_icon%type default null,
    p_fev_button_highlight in boolean default false,
    p_fev_confirm_message in fsm_event.fev_confirm_message%type default null,
    p_fev_active in boolean default true);
    
  /** Deletes an event
   * @param  p_fcl_id  ID of the event
   * @param [p_force]  Flag indicating whether all pending transits should also be deleted (TRUE) or not. Default: FALSE
   * @usage  Used to remove an event and optionally all pending transitions
   */
  procedure delete_event(
    p_fev_id in fsm_event.fev_id%type,
    p_force in boolean default false);
    
    
  /** Creates or modifies a transition
   * @param  p_ftr_fst_id               Reference to the status
   * @param  p_ftr_fev_id               Reference to the event
   * @param  p_ftr_fcl_id               Reference to the class
   * @param  p_ftr_fst_list             ':'-separated list of status that can be reached when raising the given event
   * @param [p_ftr_raise_automatically] Flag to indicate whether this event is to be called automatically (TRUE) or not.
   *                                    If FALSE, the transition waits for the event to be fired externally.
   * @param [p_ftr_raise_on_status]     Flag to indicate whether this transition is fired upon normal execution (C_OK) or
   *                                    in case of an error (C_ERROR)
   * @param [p_ftr_required_role]       Optional reference to a role that is required to perform this transition
   * @param [p_ftr_active]              Flag to indicate whether this transition is actually used
   * @usage  Is used to maintain transition meta data at table FSM_TRANSITION.
   */
 procedure  merge_transition(
    p_ftr_fst_id in fsm_transition.ftr_fst_id%type,
    p_ftr_fev_id in fsm_transition.ftr_fev_id%type,
    p_ftr_fcl_id in fsm_transition.ftr_fcl_id%type,
    p_ftr_fst_list in fsm_transition.ftr_fst_list%type,
    p_ftr_raise_automatically in boolean,
    p_ftr_raise_on_status in fsm_transition.ftr_raise_on_status%type default 0,
    p_ftr_required_role in fsm_transition.ftr_required_role%type default null,
    p_ftr_active in boolean default true);
    
    
  /** Deletes a transition
   * @param  p_ftr_fst_id  Reference to the status
   * @param  p_ftr_fev_id  Reference to the event
   * @param  p_ftr_fcl_id  Reference to the class
   * @usage  Used to remove a transition
   */
  procedure delete_transition(
    p_ftr_fst_id in fsm_transition.ftr_fst_id%type,
    p_ftr_fev_id in fsm_transition.ftr_fev_id%type,
    p_ftr_fcl_id in fsm_transition.ftr_fcl_id%type);
    
  
  /* Procedure to create a constant package for all events */
  procedure create_event_package;
    
  /* Procedure to create a constant package for all status */
  procedure create_status_package;
  
  /** Method to export a class including all referenced messages
   * @param  p_fcl_id  ID of the class to export
   * @return CLOB instance containing a script with method calls to import the class
   * @usage  Is used to create an export script with all meta data for a FSM
   */
  function export_class(
    p_fcl_id in fsm_class.fcl_id%type)
    return clob;
  
end fsm_admin_pkg;
/

