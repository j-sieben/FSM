# Klasse, Status und Ereignisse definieren

Klasse, Status und Ereignisse bilden die Grundelemente des fachlichen Zustandsgraphen. Sie werden mit `FSM_ADMIN` registriert, bevor Transitionen angelegt werden.

## Installationsreihenfolge

1. konkreten SQL-Subtyp erstellen
2. Klasse registrieren
3. benötigte Subklassen und Statusgruppen anlegen
4. Status registrieren
5. Ereignisse registrieren
6. [[03_FSM-verwenden/Transitionen-und-Autoevents-definieren|Transitionen und Autoevents definieren]]
7. Metadaten prüfen und Konstantenpackages erzeugen

## Klasse registrieren

Die Klasse verbindet den fachlichen Graphen mit dem konkreten SQL-Subtyp:

```sql
fsm_admin.merge_class(
  p_fcl_id => 'REQ',
  p_fcl_type_name => 'FSM_REQ_TYPE',
  p_fcl_name => 'Berechtigungsanforderung',
  p_fcl_description => 'Anforderung für eine Datenbankberechtigung');
```

`FCL_ID` identifiziert die Klasse in den folgenden Metadaten. `FCL_TYPE_NAME` muss ein sichtbarer, instanziierbarer Subtyp von `FSM_TYPE` sein.

## Status registrieren

Pro Klasse und Subklasse muss genau ein aktiver Initialstatus erreichbar sein. Terminale Status kennzeichnen den fachlichen Abschluss. Retry-, Eskalations- und Darstellungsangaben gehören ebenfalls zum Status.

```sql
fsm_admin.merge_status(
  p_fst_id => 'CREATED',
  p_fst_fcl_id => 'REQ',
  p_fst_msg_id => 'FSM_STATUS_CHANGED',
  p_fst_name => 'Antrag erstellt',
  p_fst_initial_status => true);

fsm_admin.merge_status(
  p_fst_id => 'GRANTED',
  p_fst_fcl_id => 'REQ',
  p_fst_msg_id => 'REQ_GRANTED',
  p_fst_name => 'Genehmigt',
  p_fst_terminal_status => true);
```

## Ereignisse registrieren

Ereignisse bezeichnen fachliche Kommandos oder technische Auslöser. Angaben wie `FEV_RAISED_BY_USER` steuern, ob ein Ereignis durch einen Benutzer angeboten werden darf.

```sql
fsm_admin.merge_event(
  p_fev_id => 'CHECK',
  p_fev_fcl_id => 'REQ',
  p_fev_msg_id => 'FSM_EVENT_RAISED',
  p_fev_name => 'Prüfe Antrag',
  p_fev_command_label => 'Prüfen',
  p_fev_raised_by_user => false);
```

`NIL` kennzeichnet das Ende eines terminalen Pfads. Die vollständigen Metadaten der Sample-App stehen in `FSM/sample_app/scripts/create_fsm_data.sql`.

## Konstanten erzeugen

`FSM_ADMIN.CREATE_STATUS_PACKAGE` und `FSM_ADMIN.CREATE_EVENT_PACKAGE` erzeugen `FSM_FST` und `FSM_FEV`. Implementierungen verwenden diese Konstanten anstelle freier Zeichenketten.
