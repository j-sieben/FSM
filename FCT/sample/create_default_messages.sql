begin

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._COMPLETED',
    p_message_text => q'ø&TOOLKIT. has succesfully completed.ø',
    p_severity => 70,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._COMPLETED',
    p_message_text => q'ø&TOOLKIT. erfolgreich abgeschlossen.ø',
    p_message_language => 'GERMAN'
  );
  
  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._REQ_REJECTED',
    p_message_text => q'øYour request was rejected.ø',
    p_severity => 40,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._REQ_REJECTED',
    p_message_text => q'øIhre Anfrage wurde abgelehnt.ø',
    p_message_language => 'GERMAN'
  );
  
  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._REQ_GRANTED',
    p_message_text => q'øYour request was granted.ø',
    p_severity => 50,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._REQ_GRANTED',
    p_message_text => q'øIhre Anfrage wurde akzeptiert.ø',
    p_message_language => 'GERMAN'
  );
  
  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._REQ_PENDING',
    p_message_text => q'øYour request is waiting for a decision.ø',
    p_severity => 50,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._REQ_PENDING',
    p_message_text => q'øIhre Anfrage wartet auf Entscheidung.ø',
    p_message_language => 'GERMAN'
  );

  commit;
  pit_admin.create_message_package;
end;
/
