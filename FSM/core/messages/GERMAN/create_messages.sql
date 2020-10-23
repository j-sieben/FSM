begin

  pit_admin.merge_message_group(
    p_pmg_name => 'FSM',
    p_pmg_description => 'Meldungen für &Toolkit.'
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_COMPLETED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^fsm erfolgreich abgeschlossen.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_CREATED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^#1#-fsm mit ID #2# erstellt.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'FSM_NEXT_STATUS_NU',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'~Nächster Status nach "#1#" konnte nicht ermittelt werden, da er nicht eindeutig ist.~',
    p_pms_description => q'^Wird der nächste Status automatisch berechnet, muss sichergestellt sein, dass nur ein resultierender Status ermittelt wird, die Berechnung muss deterministisch sein.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'GERMAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_EVENT_NOT_ALLOWED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Ereignis "#1#" ist im aktuellen Status "#2#" nicht erlaubt.^',
    p_pms_description => q'^Das angeforderte Ereignis ist laut Transistionstabelle nicht erlaubt. Stellen Sie sicher, dass alle erlaubten Transitionen erfasst wurden oder vermeiden Sie, ein nicht zugewiesenes Ereigenis auszulösen.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'GERMAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_EVENT_RAISED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Ereignis "#1#" erkannt.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_HAS_AUTO_EVENT',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Status "#1#" hat bereits einen automatischen Ereignis und erlaubt keine manuellen Ereigniss.^',
    p_pms_description => q'^Wird einem Status ein automatisch auslösendes Ereignis zugeordnet, dürfen nicht parallel auch manuell auslösende Ereignisse zugeordnet werden.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'GERMAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_ID_DOES_NOT_EXIST',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^fsm_ID #1# existiert nicht, es wurde keine Aktion gestartet.^',
    p_pms_description => q'^Es wurde versucht, eine fsm-Instanz zu erzeugen, die nicht persistiert ist. Stellen Sie sicher, nur existierende Objekte zu instanziieren oder erstellen Sie eine neue Instanz.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'GERMAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_INVALID_EVENT',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Handler für das fsm-Ereignis "#1#" ist in Status "#2#" nicht erlaubt.^',
    p_pms_description => q'^Das angeforderte Ereignis ist im aktuellen Status der Instanz nicht erlaubt. Stellen Sie sicher, dass alle erforderlichen Ereignisse in den Transitionen erfasst sind oder vermeiden Sie das auslösen nicht erlaubter Ereignisse.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'GERMAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_MANUAL_AUTO_EVENT',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Status "#1#" hat sowohl automatische als auch manuelle Ereignisse.^',
    p_pms_description => q'^Ein Status mit einem automatisch auslösenden Ereignis farf keine manuell ausgelösten Ereignisse besitzen.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'GERMAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_MISSING_EVENT_HANDLER',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Handler für das fsm-Ereignis #1# konnte in Package #2# nicht gefunden werden.^',
    p_pms_description => q'^Ein Ereignis wurde ausgelöst, das keinen Ereignis-Handler im zugehörigen Package besitzt. Stellen Sie sicher, dass alle Ereignisse einer Klasse auch einen Ereignis-Handler besitzen.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'GERMAN',
    p_error_number => -302
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_MULTI_AUTO_EVENT',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Status "#1#" hat mehrere automatische Ereignisse.^',
    p_pms_description => q'^Ein Status darf nur maximal ein automatisch auslösendes Ereignis besitzen. Entfernen Sie die zusätzlichen Ereignisse.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'GERMAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_NEXT_EVENTS',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Nächste erlaubte Ereignisse: "#1#", automatisch auslösen: #2#.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'FSM_NEXT_STATUS',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'~Nächster Status "#1#" wurde ermittelt.~',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'FSM_NEXT_STATUS_NU',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'~Nächster Status nach "#1#" konnte nicht ermittelt werden, da er nicht eindeutig ist.~',
    p_pms_description => q'^Die Transition erlaubt nicht die automatische Ermittlung des nächsten Status. Stellen Sie sicher, dass die Auswertung deterministisch ist, wenn Sie den nächsten Status automatisiert ermitteln lassen.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'GERMAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_NO_PL_SCOPE',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^PL/Scope ist für dieses Instanz nicht aktiviert, verwende eine weniger sichere Strategie zum Prüfen des Packages.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 40,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_PACKAGE_MISSING',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Ereignis-Handler-Package für die Klasse "#1#" fehlt.^',
    p_pms_description => q'^Eine fsm-Klasse erfordert immer auch ein Package, das die Ereignis-HGandler implementiert.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'GERMAN',
    p_error_number => -201
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_PKG_NOT_EXISTING',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Das Package #1#, das Sie prüfen möchten, existiert nicht.^',
    p_pms_description => q'^Stellen Sie sicher, dass das richtige Package zur Prüfung angegeben wird.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'GERMAN',
    p_error_number => -20000
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_RETRY_INFO',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Erneuter Verarbeitungsversuch.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 60,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_RETRYING',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Ein Fehler trat bei Ereignis "#1#" in Status "#2#" im Übergang zu Status "#3#" auf, #4#. Wiederholung.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 50,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_RETRY_REQUESTED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Wiederholung von Ereignis "#1#" angefordert. Status: "#2#", Wdhlg. möglich: #3#.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 60,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_RETRY_WARN',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Letzter Verarbeitungsversuch.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 50,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_STATUS_CHANGED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^fsm-Status auf "#1#" geändert.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 60,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_SUCCESS',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Objekt erfolgreich verarbeitet.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_TEST_COMPLETED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Test abgeschlossen.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_THROW_ERROR_EVENT',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Werfe Fehler-Ereignis: "#1#".^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );

  pit_admin.merge_message(
    p_pms_name => 'FSM_VALIDITY',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Aktuelle Gültigkeit: #1#.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'UNABLE_TO_ACHIEVE_STATUS',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Aufgrund eines Fehlers konnte Status "#1#" nicht erreicht werden.^',
    p_pms_description => q'^Tritt ein Fehler auf, kann fsm den nächsten Status nicht erreichen. Stattdessen geht das Objekt in einen Fehlerstatus.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'GERMAN',
    p_error_number => -20000
  );

  
  pit_admin.merge_message(
    p_pms_name => 'FSM_SQL_ERROR',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^FSM #1#, ID: #2#, Ereignis: "#3#"^',
    p_pms_description => q'^Generische Nachricht für SQL-Fehlermeldung während der fsm-Verarbeitung.^',
    p_pms_pse_id => 30,
    p_pms_pml_name => 'GERMAN',
    p_error_number => -20000
  );
  
  pit_admin.merge_message(
    p_pms_name => 'FSM_NEXT_STATUS_RECOGNIZED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^Nächster Status "#1#" erkannt.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 70,
    p_pms_pml_name => 'GERMAN'
  );
  
  pit_admin.merge_message(
    p_pms_name => 'FSM_EVENT_NOT_AUTHORIZED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^fsm-Ereignis "#1#" wurde angefordert, ist für diesen Benutzer aber nicht autorisiert.^',
    p_pms_description => q'^Ein Ereignis mit einer Anwenderrolle wurde durch einen Benutzer angefordert, der diese Berechtigung nicht besitzt.^',
    p_pms_pse_id => 40,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'FSM_FINAL_STATE',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^fsm hat die Vearbeitung abgeschlossen.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 40,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );
  
  pit_admin.merge_message(
    p_pms_name => 'FSM_DELIVERY_FAILED',
    p_pms_pmg_name => 'FSM',
    p_pms_text => q'^fsm-Vearbeitung fehlgeschlagen.^',
    p_pms_description => q'^^',
    p_pms_pse_id => 40,
    p_pms_pml_name => 'GERMAN',
    p_error_number => null
  );
	
  commit;
  pit_admin.create_message_package;
end;
/