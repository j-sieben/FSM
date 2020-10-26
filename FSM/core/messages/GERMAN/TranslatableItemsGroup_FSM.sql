begin

  pit_admin.merge_message_group(
    p_pmg_name => 'FSM',
    p_pmg_description => q'^Core FSM messages and translatable items^');

  -- FSM_STATUS_SEVERITY
  pit_admin.merge_translatable_item(
    p_pti_id => 'FCL_FSM',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Finite State Machine (Zustandsautomat)',
    p_pti_description => 'Abstrakte Oberklasse, definiert Interface');

  -- FSM_STATUS_SEVERITY
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSS_ERROR',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Fehler',
    p_pti_display_name => 'Fehlerstatus',
    p_pti_description => 'Fehler');

  pit_admin.merge_translatable_item(
    p_pti_id => 'FSS_WARNING',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Warnung',
    p_pti_display_name => 'Warnung enthalten',
    p_pti_description => 'Warnung');

  pit_admin.merge_translatable_item(
    p_pti_id => 'FSS_MILESTONE',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Meilenstein',
    p_pti_display_name => 'Meilenstein erreicht',
    p_pti_description => 'Meilenstein');

  pit_admin.merge_translatable_item(
    p_pti_id => 'FSS_INFORMATION',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Information',
    p_pti_display_name => 'Information',
    p_pti_description => 'Information');

  pit_admin.merge_translatable_item(
    p_pti_id => 'FSS_VERBOSE',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Zusätzliche Information',
    p_pti_display_name => 'Zusätzliche Information',
    p_pti_description => 'Zusätzliche Information');
    
  
  -- FSM_STATUS_GROUP
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSG_FSM_CLOSED',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Abgeschlossen',
    p_pti_display_name => 'Bearbeitung wurde abgeschlossen',
    p_pti_description => 'Bearbeitung wurde abgeschlossen');
    
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSG_FSM_MANUAL',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Manuell',
    p_pti_display_name => 'Instanz wartet auf manuelle Eingabe',
    p_pti_description => 'Instanz wartet auf manuelle Eingabe');
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSG_FSM_CANCELLED',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Abgebrochen',
    p_pti_display_name => 'Automatisierte Bearbeitung wurde abgelehnt',
    p_pti_description => 'Automatisierte Bearbeitung wurde abgelehnt');
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSG_FSM_ERROR',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Fehler',
    p_pti_display_name => 'Objekt hat einen Fehler',
    p_pti_description => 'Objekt hat einen Fehler');
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSG_FSM_OPEN',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'In Bearbeitung',
    p_pti_display_name => 'Objekt ist in Bearbeitung',
    p_pti_description => 'Objekt ist in Bearbeitung');
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FSG_FSM_WARNING',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Warnung',
    p_pti_display_name => 'Objekt hat eine Warnung',
    p_pti_description => 'Objekt hat eine Warnung');
    
  -- FSM_EVENT
  pit_admin.merge_translatable_item(
    p_pti_id => 'FEV_FSM_INITIALIZE',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Initialisieren',
    p_pti_display_name => 'Initialisieren',
    p_pti_description => 'Instanz wird initialisiert');
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FEV_FSM_ERROR',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Fehler',
    p_pti_display_name => 'Fehler',
    p_pti_description => 'Ein Fehler ist aufgetreten');
    
  pit_admin.merge_translatable_item(
    p_pti_id => 'FEV_FSM_NIL',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Keine Aktion',
    p_pti_display_name => 'Keine Aktion',
    p_pti_description => 'Keine weiteren Aktivitäten');
    
  -- FSM_STATUS
  pit_admin.merge_translatable_item(
    p_pti_id => 'FST_FSM_ERROR',
    p_pti_pml_name => 'GERMAN',
    p_pti_pmg_name => 'FSM',
    p_pti_name => 'Fehler',
    p_pti_display_name => 'Fehler',
    p_pti_description => 'Verarbeitung wegen eines Fehlers gestoppt');
    
  commit;
end;
/

