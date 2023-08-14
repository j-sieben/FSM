begin

  pit_admin.merge_message_group(
    p_pmg_name => 'REQ',
    p_pmg_description => 'Messages for the FSM Request Sample Application'
  );

  pit_admin.merge_message(
    p_pms_name => 'REQ_COMPLETED',
    p_pms_pmg_name => 'REQ',
    p_pms_text => q'^REQ erfolgreich abgeschlossen.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'REQ_REJECTED',
    p_pms_pmg_name => 'REQ',
    p_pms_text => q'^Ihre Anfrage wurde abgelehnt.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 40,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'REQ_GRANTED',
    p_pms_pmg_name => 'REQ',
    p_pms_text => q'^Ihre Anfrage wurde akzeptiert.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 50,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'REQ_PENDING',
    p_pms_pmg_name => 'REQ',
    p_pms_text => q'^Ihre Anfrage wartet auf Entscheidung.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 50,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );
  
  pit_admin.merge_translatable_item(
    p_pti_id => 'OBJECT_PRIV',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'REQ',
    p_pti_name => 'Objektprivileg',
    p_pti_description => 'Antrag auf Erteilung eines Objektprivilegs');
  
  pit_admin.merge_translatable_item(
    p_pti_id => 'SYSTEM_PRIV',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'REQ',
    p_pti_name => 'Systemprivileg',
    p_pti_description => 'Antrag auf Erteilung eines Systemprivileg');

  commit;
  pit_admin.create_message_package;
end;
/
