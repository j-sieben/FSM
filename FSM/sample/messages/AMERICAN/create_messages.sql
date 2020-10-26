begin

  pit_admin.merge_message_group(
    p_pmg_name => 'REQ',
    p_pmg_description => 'Messages for the Finite Chart Toolkit'
  );

  pit_admin.merge_message(
    p_pms_name => 'REQ_COMPLETED',
    p_pms_pmg_name => 'REQ',
    p_pms_text => q'^REQ has succesfully completed.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'REQ_REQ_REJECTED',
    p_pms_pmg_name => 'REQ',
    p_pms_text => q'^Your request was rejected.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 40,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'REQ_REQ_GRANTED',
    p_pms_pmg_name => 'REQ',
    p_pms_text => q'^Your request was granted.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 50,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'R_REQ_PENDING',
    p_pms_pmg_name => 'REQ',
    p_pms_text => q'^Your request is waiting for a decision.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 50,
    p_pms_pml_name => 'AMERICAN',
    p_error_number => null
  );
  
  pit_admin.merge_translatable_item(
    p_pti_id => 'OBJECT_PRIV',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'REQ',
    p_pti_name => 'Object privilege',
    p_pti_description => 'Request to be granted a object privilege');
  
  pit_admin.merge_translatable_item(
    p_pti_id => 'SYSTEM_PRIV',
    p_pti_pml_name => 'AMERICAN',
    p_pti_pmg_name => 'REQ',
    p_pti_name => 'System privilege',
    p_pti_description => 'Request to be granted a system privilege');

  commit;
  pit_admin.create_message_package;
end;
/
