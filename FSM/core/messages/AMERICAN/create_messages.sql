begin

  pit_admin.merge_message_group(
    p_pmg_name => 'FSM',
    p_pmg_description => 'Messages for the FSM'
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_COMPLETED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^FSM has successfully completed.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_CREATED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^#1#-fsm created with ID #2#.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'FSM_NEXT_STATUS_NU',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'~Next status after #1# could not be determined, it is not unique.~',
    p_pms_description => q'^If you automatically determine the next status, make sure that this decision is deterministic and leads to only one status.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_EVENT_NOT_ALLOWED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Event #1# is not allowed at the actual status #2#.^',
    p_pms_description => q'^The requested event is not in the list of allowed events, which is derived from the transition list. Make sure that the event is allowed, or avoid raising this event in this status.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_EVENT_RAISED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Event #1# detected.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_HAS_AUTO_EVENT',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Status #1# is already connected to an automatic event and does not allow non-automatic events.^',
    p_pms_description => q'^If an event is configured to be raised automatically, it must not also be triggered manually.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_ID_DOES_NOT_EXIST',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^fsm_ID #1# does not exist, no action has been taken.^',
    p_pms_description => q'^You tried to instantiate an FSM instance that is not persisted. Make sure to instantiate only existing objects or create a new object.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_INVALID_EVENT',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Handler for FSM event #1# is not allowed at status #2#.^',
    p_pms_description => q'^The requested event is not in the list of allowed events, which is derived from the transition list. Make sure that the event is allowed, or avoid raising this event in this status.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_MANUAL_AUTO_EVENT',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Status #1# is connected to both automatic and manual events.^',
    p_pms_description => q'^A status may not be connected to both an automatic and a manual event. Make sure your transitions do not do this.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_MISSING_EVENT_HANDLER',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Handler for FSM event #1# is missing in package #2#.^',
    p_pms_description => q'^An event was raised that does not have an event handler in the respective package. Make sure that all events are handled within this package.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -302
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_MULTI_AUTO_EVENT',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Status #1# is connected to more than one automatic event.^',
    p_pms_description => q'^A status may have a maximum of one automatic event attached. Remove the superfluous events.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_NEXT_EVENTS',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Next possible events: #1#, raise automatically: #2#.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'FSM_NEXT_STATUS',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'~Next status #1# calculated.~',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_NO_PL_SCOPE',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^PL/Scope is switched off for this instance, using a less safe option to check the package.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 40,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_PACKAGE_MISSING',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Event handler package for class #1# is missing.^',
    p_pms_description => q'^A class requires a package that implements the event handlers for this class. Make sure that each class has a respective package.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -201
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_PKG_NOT_EXISTING',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^The package #1# you referenced does not exist.^',
    p_pms_description => q'^Make sure that the correct package is referenced.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_RETRY_INFO',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Retry process step.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 60,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_RETRYING',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^An error occurred for event #1# in status #2# during the transition to status #3#: #4#. Retrying.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 50,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_RETRY_REQUESTED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Retry of event #1# requested. Status: #2#, retry possible: #3#.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 60,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_RETRY_WARN',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Last retry for process step.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 50,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_STATUS_CHANGED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^FSM status changed to #1#.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 60,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_SUCCESS',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Object processed successfully.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_TEST_COMPLETED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Test completed.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_THROW_ERROR_EVENT',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Throwing error event: #1#.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_VALIDITY',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Actual validity: #1#.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'UNABLE_TO_ACHIEVE_STATUS',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Unable to achieve status #1# due to an error.^',
    p_pms_description => q'^If an error occurs, this may prevent the FSM from stepping to the next status. Instead, it proceeds to an error status.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_SQL_ERROR',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^FSM #1#, ID: #2#, Event: #3#^',
    p_pms_description => q'^Generic message for SQL errors occurring during FSM processing.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );
  
  pit_admin.merge_message(
    p_pms_name => 'FSM_NEXT_STATUS_RECOGNIZED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Next status "#1#" recognized.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'AMERICAN'
  );
  
  pit_admin.merge_message(
    p_pms_name => 'FSM_EVENT_NOT_AUTHORIZED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^FSM event #1# was requested but is not authorized for this user.^',
    p_pms_description => q'^An event that requires a user role was requested by a user who does not have the required authorization.^',
    p_pms_pse_id => 40,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'FSM_FINAL_STATE',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^FSM has completed.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 40,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'FSM_DELIVERY_FAILED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^FSM process failed.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 40,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_NO_INITIAL_STATUS',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^No initial status defined.^',
    p_pms_description => q'^Every FSM needs exactly one initial status per configured subclass so that a new instance can enter the process graph.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_TOO_MANY_INITIALS',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Initial status is not unique.^',
    p_pms_description => q'^Only one initial status per class or subclass is allowed, otherwise the runtime cannot determine where a new instance has to start.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_MULTIPLE_AUTO_EVENTS',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Status "#1#" in subclass "#2#" has multiple automatic events for result "#3#".^',
    p_pms_description => q'^At most one automatic event per status, subclass and result code is allowed. Otherwise the runtime would have more than one next action to execute automatically.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_UNREACHABLE_STATUS',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Status "#1#" of class "#2#" is unreachable.^',
    p_pms_description => q'^The status is active but cannot be reached from any initial status through the active transitions of the class.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_DEAD_END_STATUS',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Status "#1#" of class "#2#" is a dead end.^',
    p_pms_description => q'^The status is reachable but has no active outgoing transition. Terminal statuses should therefore be modeled explicitly, for example by a NIL event.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => -20000
  );
	
  commit;
  pit_admin.create_message_package;
end;
/
