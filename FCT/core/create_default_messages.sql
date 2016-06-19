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
    p_message_name => '&TOOLKIT._CREATED',
    p_message_text => q'ø#1#-&TOOLKIT. created with ID #2#.ø',
    p_severity => 70,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._CREATED',
    p_message_text => q'ø#1#-&TOOLKIT. mit ID #2# erstellt.ø',
    p_message_language => 'GERMAN'
  );
  
  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._NEXT_STATUS_NU',
    p_message_text => q'~Next status after #1# could not be determined, it is not unique.~',
    p_severity => 30,
    p_message_language => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._NEXT_STATUS_NU',
    p_message_text => q'~Nächster Status nach #1# konnte nicht ermittelt werden, da er nicht eindeutig ist.~',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._EVENT_NOT_ALLOWED',
    p_message_text => q'øEvent #1# is not allowed at the actual status #2#.ø',
    p_severity => 30,
    p_message_language => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._EVENT_NOT_ALLOWED',
    p_message_text => q'øEvent #1# ist im aktuellen Status #2# nicht erlaubt.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._EVENT_RAISED',
    p_message_text => q'øEvent #1# detected.ø',
    p_severity => 70,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._EVENT_RAISED',
    p_message_text => q'øEvent #1# erkannt.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._HAS_AUTO_EVENT',
    p_message_text => q'øStatus #1# is connected to an automatic event already and does not allow for non automatic events.ø',
    p_severity => 30,
    p_message_language => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._HAS_AUTO_EVENT',
    p_message_text => q'øStatus #1# hat bereits einen automatischen Event und erlaubt keine manuellen Events.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._ID_DOES_NOT_EXIST',
    p_message_text => q'ø&TOOLKIT._ID #1# does not exist, no action has been taken.ø',
    p_severity => 30,
    p_message_language => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._ID_DOES_NOT_EXIST',
    p_message_text => q'ø&TOOLKIT._ID #1# existiert nicht, es wurde keine Aktion gestartet.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._INVALID_EVENT',
    p_message_text => q'øHandler vor &TOOLKIT.-Event #1# is not allowed at status #2#.ø',
    p_severity => 30,
    p_message_language => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._INVALID_EVENT',
    p_message_text => q'øHandler für das &TOOLKIT.-Event #1# ist in Status #2# nicht erlaubt.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._MANUAL_AUTO_EVENT',
    p_message_text => q'øStatus #1# is connected to automatic and manual events.ø',
    p_severity => 30,
    p_message_language => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._MANUAL_AUTO_EVENT',
    p_message_text => q'øStatus #1# hat sowohl automatische als auch manuelle Events.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._MISSING_EVENT_HANDLER',
    p_message_text => q'øHandler vor &TOOLKIT.-Event #1# is missing in package #2#.ø',
    p_severity => 30,
    p_message_language => 'AMERICAN',
    p_error_number => -302
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._MISSING_EVENT_HANDLER',
    p_message_text => q'øHandler für das &TOOLKIT.-Event #1# konnte in Package #2# nicht gefunden werden.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._MULTI_AUTO_EVENT',
    p_message_text => q'øStatus #1# is connected to more than one automatic event.ø',
    p_severity => 30,
    p_message_language => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._MULTI_AUTO_EVENT',
    p_message_text => q'øStatus #1# hat mehrere automatische Events.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._NEXT_EVENTS',
    p_message_text => q'øNext possible events: #1#, raise automatically: #2#.ø',
    p_severity => 70,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._NEXT_EVENTS',
    p_message_text => q'øNächste erlaubte Events: #1#, automatisch auslösen: #2#.ø',
    p_message_language => 'GERMAN'
  );
  
  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._NEXT_STATUS',
    p_message_text => q'~Next status #1# calculated.~',
    p_severity => 70,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._NEXT_STATUS',
    p_message_text => q'~Nächster Status #1# wurde ermittelt.~',
    p_message_language => 'GERMAN'
  );
  
  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._NEXT_STATUS_NU',
    p_message_text => q'~Next status after #1# could not be determined, it is not unique.~',
    p_severity => 30,
    p_message_language => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._NEXT_STATUS_NU',
    p_message_text => q'~Nächster Status nach #1# konnte nicht ermittelt werden, da er nicht eindeutig ist.~',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._NO_PL_SCOPE',
    p_message_text => q'øPL/Scope is switched off for this instance, using a more unsafe option to check the package.ø',
    p_severity => 40,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._NO_PL_SCOPE',
    p_message_text => q'øPL/Scope ist für dieses Instanz nicht aktiviert, verwende eine weniger sichere Strategie zum Prüfen des Packages.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._PACKAGE_MISSING',
    p_message_text => q'øEvent hanlder package for class #1# is missing.ø',
    p_severity => 30,
    p_message_language => 'AMERICAN',
    p_error_number => -201
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._PACKAGE_MISSING',
    p_message_text => q'øEvent-Handler-Package für die Klasse #1# fehlt.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._PKG_NOT_EXISTING',
    p_message_text => q'øThe package #1# you referenced is not existing.ø',
    p_severity => 30,
    p_message_language => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._PKG_NOT_EXISTING',
    p_message_text => q'øDas Package #1#, das Sie prüfen möchten, existiert nicht.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._RETRY_INFO',
    p_message_text => q'øRetry process step.ø',
    p_severity => 60,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._RETRY_INFO',
    p_message_text => q'øErneuter Verarbeitungsversuch.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._RETRYING',
    p_message_text => q'øAn error occurred at event #1# in status #2# in conversion to status #3#: #4#st retryø',
    p_severity => 50,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._RETRYING',
    p_message_text => q'øEin Fehler trat bei Ereignis #1# in Status #2# im Übergang zu Status #3# auf, #4#. Wiederholung.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._RETRY_REQUESTED',
    p_message_text => q'øRetry of event #1# requested. Status: #2#, retry possible: #3#.ø',
    p_severity => 60,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._RETRY_REQUESTED',
    p_message_text => q'øWiederholung von Event #1# angefordert. Status: #2#, Wdhlg. möglich: #3#.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._RETRY_WARN',
    p_message_text => q'øLast retry for process step.ø',
    p_severity => 50,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._RETRY_WARN',
    p_message_text => q'øLetzter Verarbeitungsversuch.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._STATUS_CHANGED',
    p_message_text => q'ø&TOOLKIT.-Status changed to #1#.ø',
    p_severity => 60,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._STATUS_CHANGED',
    p_message_text => q'ø&TOOLKIT.-Status auf #1# geändert.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._SUCCESS',
    p_message_text => q'øDocument processed successfully.ø',
    p_severity => 70,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._TEST_COMPLETED',
    p_message_text => q'øTest completed.ø',
    p_severity => 70,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._TEST_COMPLETED',
    p_message_text => q'øTest abgeschlossen.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._THROW_ERROR_EVENT',
    p_message_text => q'øThrowing error event: #1#.ø',
    p_severity => 70,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._THROW_ERROR_EVENT',
    p_message_text => q'øWerfe Fehler-Event: #1#.ø',
    p_message_language => 'GERMAN'
  );

  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._VALIDITY',
    p_message_text => q'øActual validity: #1#.ø',
    p_severity => 70,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._VALIDITY',
    p_message_text => q'øAktuelle Gültigkeit: #1#.ø',
    p_message_language => 'GERMAN'
  );
  
  pit_admin.merge_message(
    p_message_name => 'UNABLE_TO_ACHIEVE_STATUS',
    p_message_text => q'øUnable to achieve status #1# due to an error.ø',
    p_severity => 30,
    p_message_language => 'AMERICAN',
    p_error_number => -20000
  );

  pit_admin.translate_message(
    p_message_name => 'UNABLE_TO_ACHIEVE_STATUS',
    p_message_text => q'øAufgrund eines Fehlers konnte Status #1# nicht erreicht werden.ø',
    p_message_language => 'GERMAN'
  );

  
  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._SQL_ERROR',
    p_message_text => q'øFSM #1#, ID: #2#, Event: #3#ø',
    p_severity => 30,
    p_message_language => 'AMERICAN',
    p_error_number => -20000
  );
  
  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._NEXT_STATUS_RECOGNIZED',
    p_message_text => q'øNext status "#1#" recognized.ø',
    p_severity => 70,
    p_message_language => 'AMERICAN'
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._NEXT_STATUS_RECOGNIZED',
    p_message_text => q'øNächster Status "#1#" erkannt.ø',
    p_message_language => 'GERMAN'
  );
  
  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._EVENT_NOT_AUTHORIZED',
    p_message_text => q'ø&TOOLKIT.-event #1# but is not authorized for this user.ø',
    p_severity => 40,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._EVENT_NOT_AUTHORIZED',
    p_message_text => q'ø&TOOLKIT.-Event #1# wurde angefordert, ist für diesen Benutzer aber nicht autorisiert.ø',
    p_message_language => 'GERMAN'
  );
  
  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._FINAL_STATE',
    p_message_text => q'ø&TOOLKIT. has completed.ø',
    p_severity => 40,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._FINAL_STATE',
    p_message_text => q'ø&TOOLKIT. hat die Bearbeitung abgeschlossen.ø',
    p_message_language => 'GERMAN'
  );
  
  pit_admin.merge_message(
    p_message_name => '&TOOLKIT._DELIVERY_FAILED',
    p_message_text => q'ø&TOOLKIT. process failed.ø',
    p_severity => 40,
    p_message_language => 'AMERICAN',
    p_error_number => null
  );

  pit_admin.translate_message(
    p_message_name => '&TOOLKIT._DELIVERY_FAILED',
    p_message_text => q'ø&TOOLKIT. Bearbeitung fehlgeschlagen.ø',
    p_message_language => 'GERMAN'
  );
	
  commit;
  pit_admin.create_message_package;
end;
/
