create or replace package fsm_admin
  authid definer 
as
  
  /** 
    Procedure: merge_class
      Creates or modifies a class.
      
    Parameters:
      p_fcl_id - ID of the class
      p_fcl_name - Plain text identifier of the class
      p_fcl_description - Description of the class
      p_fcl_active - Optional flag indicating whether the class should be used (TRUE) or not (FALSE)
   */
  procedure merge_class(
    p_fcl_id in fsm_classes_v.fcl_id%type,
    p_fcl_name in fsm_classes_v.fcl_name%type,
    p_fcl_description in fsm_classes_v.fcl_description%type,
    p_fcl_active in boolean default true);
    
  procedure merge_class(
    p_row fsm_classes_v%rowtype);
    
  
  /** 
    Procedure: delete_class
      Used to remove a class and optionally all its associated events, states and transitions
      
    Parameters:
      p_fcl_id  ID of the class
      p_force - Optional flag indicating whether all referenced objects should also be deleted (TRUE) or not. Default: FALSE
   */
  procedure delete_class(
    p_fcl_id in fsm_classes_v.fcl_id%type,
    p_force in boolean default false);
       
  
  /** 
    Procedure: merge_status_group
      Creates or modifies a status group
      
    Parameters:
      p_fsg_id - ID of the status group
      p_fsg_fcl_id - Reference to FSM_CLASSES
      p_fsg_name - Display name of the status group
      p_fsg_description - Description of the status group. May be used in tooltips
      p_fsg_icon_css - Optional CSS-class to decorate status group with an icon
      p_fsg_name_css - Optional CSS-class to decorate status group name
      p_fst_active - Optional flag to indicate whether this status group is actually used or not. Defaults to TRUE.
   */
  procedure merge_status_group(
    p_fsg_id in fsm_status_groups_v.fsg_id%type,
    p_fsg_fcl_id in fsm_status_groups_v.fsg_fcl_id%type,
    p_fsg_name in fsm_status_groups_v.fsg_name%type,
    p_fsg_description in fsm_status_groups_v.fsg_description%type,
    p_fsg_icon_css in fsm_status_groups_v.fsg_icon_css%type default null,
    p_fsg_name_css in fsm_status_groups_v.fsg_name_css%type default null,
    p_fsg_active in boolean default true);
    
  procedure merge_status_group(
    p_row fsm_status_groups_v%rowtype);
    
    
  /** 
    Procedure: delete_status_group
      Deletes a status group and optionally all pending states and transitions.
      
    Parameters:
      p_fsg_id - ID of the status group
      p_force - Optional flag indicating whether all pending statuses and their transitions 
                should also be deleted (TRUE) or not. Default: FALSE
   */
  procedure delete_status_group(
    p_fsg_id in fsm_status_groups_v.fsg_id%type,
    p_fsg_fcl_id in fsm_status_groups_v.fsg_fcl_id%type,
    p_force in boolean default false);
    
    
  /**
    Procedure: merge_status_severity
      Creates a status severity representation. Main focus is to map PIT severities
      to FSM severities such as Milestone or similar.
      
    Parameters:
      p_fss_id - Numeric severity as defined in PIT, ranges from 10 .. 70 in increments of 10
      p_fss_fcl_id - Reference to FSM_CLASSES.
      p_fss_name - Display name of the severity
      p_fss_html - HTML expresssion for display purposes
      p_fss_icon - HTML CSS classes to display a status icon
   */
  procedure merge_status_severity(
    p_fss_id in fsm_status_severities_v.fss_id%type,
    p_fss_fcl_id in fsm_status_severities_v.fss_fcl_id%type,
    p_fss_name in fsm_status_severities_v.fss_name%type,
    p_fss_description in fsm_status_severities_v.fss_description%type,
    p_fss_html in fsm_status_severities_v.fss_html%type,
    p_fss_icon in fsm_status_severities_v.fss_icon%type);
    
  procedure merge_status_severity(
    p_row fsm_status_severities_v%rowtype);
    
    
  /**
    Procedure: delete_status_severity
      Deletes a status severity.
      
    Parameters:
      p_fss_id - Numeric severity as defined in PIT, ranges from 10 .. 70 in increments of 10
      p_fss_fcl_id - Reference to FSM_CLASSES.
   */
  procedure delete_status_severity(
    p_fss_id in fsm_status_severities_v.fss_id%type,
    p_fss_fcl_id in fsm_status_severities_v.fss_fcl_id%type);
    
  
  /** 
    Procedure: merge_status
      Creates or modifies a status.
      
    Parameters:
      p_fst_id - ID of the status
      p_fst_fcl_id - Reference to the class the status belongs to
      p_fst_fsg_id - Reference to a status group
      p_fst_name - Display name of the status
      p_fst_description - Description of the status. May be used in tooltips
      p_fst_severity - Severity of the status, reference to FSM_STATUS_SEVERITIES_V
      p_fst_msg_id - Optional name of the message used for logging
      p_fst_retries_on_error - Optional number of retries allowed to enter this status
      p_fst_retry_schedule - Optional schedule if a retry is executed. Controls when this retry takes place
      p_fst_retry_time - Optional duration in seconds the retry is hold back
      p_fst_icon_css - Optional CSS-class to decorate status with an icon
      p_fst_name_css - Optional CSS-class to decorate status name
      p_fst_active - Optional flag to indicate whether this event is used (TRUE) or not (FALSE). Defaults to TRUE.
   */
  procedure merge_status(
    p_fst_id in fsm_status_v.fst_id%type,
    p_fst_fcl_id in fsm_status_v.fst_fcl_id%type,
    p_fst_fsg_id in fsm_status_v.fst_fsg_id%type,
    p_fst_name in fsm_status_v.fst_name%type,
    p_fst_description in fsm_status_v.fst_description%type,
    p_fst_severity in fsm_status_v.fst_severity%type,
    p_fst_msg_id in fsm_status_v.fst_msg_id%type default msg.FSM_STATUS_CHANGED,
    p_fst_retries_on_error in fsm_status_v.fst_retries_on_error%type default 0,
    p_fst_retry_schedule in fsm_status_v.fst_retry_schedule%type default null,
    p_fst_retry_time in fsm_status_v.fst_retry_time%type default null,
    p_fst_icon_css in fsm_status_v.fst_icon_css%type default null,
    p_fst_name_css in fsm_status_v.fst_name_css%type default null,
    p_fst_active in boolean default true);
    
  procedure merge_status(
    p_row in fsm_status_v%rowtype);
    
  /** 
    Procedure: delete_status
      Deletes a status and optionally all pending transitions
      
    Parameters:
      p_fst_id - ID of the status
      p_fst_fcl_id - Reference to the class the status belongs to
      p_force - Optional flag indicating whether all pending transitions should 
                also be deleted (TRUE) or not. Default: FALSE
   */
  procedure delete_status(
    p_fst_id in fsm_status_v.fst_id%type,
    p_fst_fcl_id in fsm_status_v.fst_fcl_id%type,
    p_force in boolean default false);
    
    
  /** 
    Procedure: merge_event
      Creates or modifies an event.
      
    Parameters:
      p_fev_id - ID of the event
      p_fev_fcl_id - Reference to the class the event belongs to
      p_fev_name - Display name of the event
      p_fev_description - Description of the event. May be used in tooltips
      p_fev_msg_id - Optional name of the message used for logging. Defaults to msg.FSM_EVENT_RAISED
      p_fev_raised_by_user - Optional flag to indicate whether this event has to be raised by human interaction
      p_fev_command - Optional name of a command.
      p_fev_button_icon - Optional icon for a command button
      p_fev_button_highlight - Optional flag to indicate whether this is a default option
      p_fev_confirm_message - Optional message that is shown as a confirmation message before executing the command
      p_fev_active - Optional flag to indicate whether this event is used (TRUE) or not (FALSE). Defaults to TRUE.
   */
  procedure merge_event(
    p_fev_id in fsm_events_v.fev_id%type,
    p_fev_fcl_id in fsm_events_v.fev_fcl_id%type,
    p_fev_name in fsm_events_v.fev_name%type,
    p_fev_description in fsm_events_v.fev_description%type,
    p_fev_msg_id in fsm_events_v.fev_msg_id%type default msg.FSM_EVENT_RAISED,
    p_fev_raised_by_user in boolean default false,
    p_fev_command_label in fsm_events_v.fev_command_label%type default null,
    p_fev_button_icon in fsm_events_v.fev_button_icon%type default null,
    p_fev_button_highlight in boolean default false,
    p_fev_confirm_message in fsm_events_v.fev_confirm_message%type default null,
    p_fev_active in boolean default true);
    
  procedure merge_event(
    p_row in fsm_events_v%rowtype);
    
    
  /**
    Procedure: delete_event
      Deletes an event and optionally all pending transitions
      
    Parameters:
      p_fcl_id - ID of the event
      p_fev_fcl_id - Reference to the class the event belongs to
      p_force - Optional flag indicating whether all pending transits should also be deleted (TRUE) or not. Default: FALSE
   */
  procedure delete_event(
    p_fev_id in fsm_events_v.fev_id%type,
    p_fev_fcl_id in fsm_events_v.fev_fcl_id%type,
    p_force in boolean default false);
    
    
  /**
    Procedure: merge_transition
      Creates or modifies a transition
      
    Parameters:
      p_ftr_fst_id - Reference to the status
      p_ftr_fev_id - Reference to the event
      p_ftr_fcl_id - Reference to the class
      p_ftr_fst_list - ':'-separated list of status that can be reached when raising the given event
      p_ftr_raise_automatically - Optional flag to indicate whether this event is to be called automatically (TRUE) or not.
                                  If FALSE, the transition waits for the event to be fired externally.
      p_ftr_raise_on_status - Optional flag to indicate whether this transition is fired upon normal execution (C_OK) or
                              in case of an error (C_ERROR). Defaults to fsm.C_OK
      p_ftr_required_role - Optional reference to a role that is required to perform this transition
      p_ftr_active - Optional flag to indicate whether this transition is actually used. Defaults to TRUE
   */
 procedure  merge_transition(
    p_ftr_fst_id in fsm_transitions_v.ftr_fst_id%type,
    p_ftr_fev_id in fsm_transitions_v.ftr_fev_id%type,
    p_ftr_fcl_id in fsm_transitions_v.ftr_fcl_id%type,
    p_ftr_fst_list in fsm_transitions_v.ftr_fst_list%type,
    p_ftr_raise_automatically in boolean,
    p_ftr_raise_on_status in fsm_transitions_v.ftr_raise_on_status%type default fsm.C_OK,
    p_ftr_required_role in fsm_transitions_v.ftr_required_role%type default null,
    p_ftr_active in boolean default true);
    
  procedure merge_transition(
    p_row fsm_transitions_v%rowtype);
    
    
  /**
    Procedure: delete_transition
      Deletes a transition
      
    Parameters:
      p_ftr_fst_id - Reference to the status
      p_ftr_fev_id - Reference to the event
      p_ftr_fcl_id - Reference to the class
   */
  procedure delete_transition(
    p_ftr_fst_id in fsm_transitions_v.ftr_fst_id%type,
    p_ftr_fev_id in fsm_transitions_v.ftr_fev_id%type,
    p_ftr_fcl_id in fsm_transitions_v.ftr_fcl_id%type);
    
  
  /*+
    Procedure: create_event_package
      Method to create a constant package for all events */
  procedure create_event_package;
  
    
  /**
    Procedure: create_status_package
      Method to create a constant package for all status */
  procedure create_status_package;
  
  
  /**
    Procedure export_class
      Method to export a class including all referenced messages. Creates an export script with all meta data for a FSM
      
    Parameter:
      p_fcl_id - ID of the class to export
      
    Returns:
      CLOB instance containing a script with method calls to import the class
   */
  function export_class(
    p_fcl_id in fsm_classes_v.fcl_id%type)
    return clob;
  
end fsm_admin;
/

