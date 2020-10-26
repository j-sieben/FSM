begin

  pit_admin.merge_message_group(
    p_pmg_name => 'FSM',
    p_pmg_description => q'^Core FSM messages and translatable items^');

  -- FSM_STATUS_SEVERITY
  pit_admin.merge_translatable_item(
    p_pti_id => 'FCL_FSM',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Finite State Machine',
    p_pti_description => 'Abstract superclass, defines interface');

  -- FSM_STATUS_SEVERITY
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSS_ERROR',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Error',
    p_pti_display_name => 'Error state',
    p_pti_description => 'Error');

  pit_admin.merge_translatable_item(
    p_pti_id => 'FSS_WARNING',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Warning',
    p_pti_display_name => 'Warning exists',
    p_pti_description => 'Warning');

  pit_admin.merge_translatable_item(
    p_pti_id => 'FSS_MILESTONE',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Milestone',
    p_pti_display_name => 'Milestone reached',
    p_pti_description => 'Milestone');

  pit_admin.merge_translatable_item(
    p_pti_id => 'FSS_INFORMATION',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Information',
    p_pti_display_name => 'Information',
    p_pti_description => 'Information');

  pit_admin.merge_translatable_item(
    p_pti_id => 'FSS_VERBOSE',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Additional Information',
    p_pti_display_name => 'Additional Information',
    p_pti_description => 'Additional Information');
    
  
  -- FSM_STATUS_GROUP
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSG_FSM_CLOSED',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Closed',
    p_pti_display_name => 'Processing was completed',
    p_pti_description => 'Processing was completed');
    
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSG_FSM_MANUAL',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Manual',
    p_pti_display_name => 'Instance waiting for manual input',
    p_pti_description => 'Instance waiting for manual input');
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSG_FSM_CANCELLED',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Cancelled',
    p_pti_display_name => 'Automatisierte Bearbeitung wurde abgelehnt',
    p_pti_description => 'Automatisierte Bearbeitung wurde abgelehnt');
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSG_FSM_ERROR',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Fehler',
    p_pti_display_name => 'Objekt hat einen Fehler',
    p_pti_description => 'Objekt hat einen Fehler');
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSG_FSM_OPEN',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Open',
    p_pti_display_name => 'Object is in process',
    p_pti_description => 'Object in process');
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSG_FSM_WARNING',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Warning',
    p_pti_display_name => 'Object has a warning',
    p_pti_description => 'Object has a warning');
    
  -- FSM_EVENT
  pit_admin.merge_translatable_item(
    p_pti_id => 'FEV_FSM_INITIALIZE',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Initialize',
    p_pti_display_name => 'Initialize',
    p_pti_description => 'Instance is initialized');
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FEV_FSM_ERROR',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Error',
    p_pti_display_name => 'Error',
    p_pti_description => 'An error has occurred');
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FEV_FSM_NIL',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'No action',
    p_pti_display_name => 'No action',
    p_pti_description => 'No further activities');
    
  -- FSM_STATUS
  pit_admin.merge_translatable_item(
    p_pti_id => 'FST_FSM_ERROR',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Error',
    p_pti_display_name => 'Error',
    p_pti_description => 'Processing stopped due to an error');
    
  commit;
end;
/

