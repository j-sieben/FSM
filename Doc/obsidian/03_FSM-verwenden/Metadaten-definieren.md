# Metadaten definieren

Die Metadaten beschreiben den fachlichen Zustandsgraphen des eigenen Projekts. Das Projekt registriert seine FSM-Klasse, Status, Ereignisse und Transitionen beim Framework. Der Laufzeitkern wertet diese Angaben anschließend für jede konkrete Instanz aus.

## Installationsreihenfolge

1. konkreten SQL-Subtyp erstellen
2. Klasse mit `FSM_ADMIN.MERGE_CLASS` registrieren
3. Subklassen und Statusgruppen anlegen
4. Status und Ereignisse anlegen
5. Transitionen definieren
6. Metadatenprüfung ausführen
7. Konstantenpackages erzeugen

`MERGE_CLASS` prüft, ob `FCL_TYPE_NAME` als instanziierbarer Subtyp von `FSM_TYPE` sichtbar ist.

## Beispielklasse `REQ` registrieren

Die Sample-App modelliert den Lebenszyklus einer Berechtigungsanfrage. Sie registriert die Klasse `REQ` und verbindet sie mit dem konkreten Objekttyp `FSM_REQ_TYPE`:

```sql
fsm_admin.merge_class(
  p_fcl_id => 'REQ',
  p_fcl_type_name => 'FSM_REQ_TYPE',
  p_fcl_name => 'Berechtigungsanforderung',
  p_fcl_description => 'Anforderung für eine Datenbankberechtigung');
```

`P_FCL_ID` identifiziert die Klasse in sämtlichen folgenden Metadaten. `P_FCL_TYPE_NAME` stellt die Verbindung zur PL/SQL-Implementierung her.

## Status

Pro Klasse und Subklasse ist genau ein Initialstatus erreichbar. Terminale Status schließen den regulären Ereignisablauf ab. Retry- und Eskalationswerte gehören zum Status.

Die Sample-App definiert `CREATED` als Initialstatus sowie `GRANTED` und `REJECTED` als terminale Status:

```sql
fsm_admin.merge_status(
  p_fst_id => 'CREATED',
  p_fst_fcl_id => 'REQ',
  p_fst_fsg_id => null,
  p_fst_msg_id => 'FSM_STATUS_CHANGED',
  p_fst_name => 'Antrag erstellt',
  p_fst_description => 'Der Antrag wurde erstellt',
  p_fst_severity => fsm.C_STORY_STEP,
  p_fst_initial_status => true);

fsm_admin.merge_status(
  p_fst_id => 'GRANTED',
  p_fst_fcl_id => 'REQ',
  p_fst_fsg_id => null,
  p_fst_msg_id => 'REQ_GRANTED',
  p_fst_name => 'Genehmigt',
  p_fst_description => 'Die Anfrage wurde genehmigt',
  p_fst_severity => fsm.C_STORY_TERMINAL,
  p_fst_terminal_status => true);

fsm_admin.merge_status(
  p_fst_id => 'REJECTED',
  p_fst_fcl_id => 'REQ',
  p_fst_fsg_id => null,
  p_fst_msg_id => 'REQ_REJECTED',
  p_fst_name => 'Abgelehnt',
  p_fst_description => 'Der Antrag wurde abgelehnt',
  p_fst_severity => fsm.C_STORY_TERMINAL,
  p_fst_terminal_status => true);
```

Damit besitzt jede neue Anfrage einen eindeutigen Einstieg und zwei fachlich unterschiedliche Abschlüsse.

## Ereignisse

`INITIALIZE` startet die automatische Verarbeitung einer neuen Anfrage. `CHECK` führt die fachliche Prüfung aus. `GRANT` und `REJECT` bilden die Entscheidungen ab. `NIL` kennzeichnet das Ende eines terminalen Pfads.

```sql
fsm_admin.merge_event(
  p_fev_id => 'INITIALIZE',
  p_fev_fcl_id => 'REQ',
  p_fev_msg_id => 'FSM_EVENT_RAISED',
  p_fev_name => 'Initialisieren',
  p_fev_description => 'Initialisiere Antrag',
  p_fev_command_label => 'Initialisieren',
  p_fev_raised_by_user => false);

fsm_admin.merge_event(
  p_fev_id => 'CHECK',
  p_fev_fcl_id => 'REQ',
  p_fev_msg_id => 'FSM_EVENT_RAISED',
  p_fev_name => 'Prüfe Antrag',
  p_fev_description => 'Der eingegangene Antrag wird geprüft',
  p_fev_command_label => 'Prüfen',
  p_fev_raised_by_user => false);
```

## Transition

Eine Transition verbindet Quellstatus und Ereignis mit einer Liste möglicher Zielstatus. Zusätzlich können Autoauslösung, Ergebnisstatus, Rolle und Übergangsgrund konfiguriert werden.

Der Initialstatus löst automatisch `INITIALIZE` aus und führt nach `IN_PROCESS`. Dort löst die FSM automatisch `CHECK` aus. Die Fachlogik in `FSM_REQ.RAISE_CHECK` wählt anschließend anhand von `BL_REQUEST.GET_GRANT_MODE` einen der drei möglichen Zielstatus.

```sql
fsm_admin.merge_transition(
  p_ftr_fst_id => 'CREATED',
  p_ftr_fev_id => 'INITIALIZE',
  p_ftr_fcl_id => 'REQ',
  p_ftr_fst_list => 'IN_PROCESS',
  p_ftr_raise_automatically => true,
  p_run_checks => false);

fsm_admin.merge_transition(
  p_ftr_fst_id => 'IN_PROCESS',
  p_ftr_fev_id => 'CHECK',
  p_ftr_fcl_id => 'REQ',
  p_ftr_fst_list =>
    'GRANT_AUTOMATICALLY:GRANT_MANUALLY:GRANT_SUPERVISOR',
  p_ftr_raise_automatically => true,
  p_run_checks => false);
```

Ein manueller Genehmigungspfad führt über `GRANT` zum Terminalstatus `GRANTED`. Ein `NIL`-Übergang markiert anschließend das Ende des Graphen:

```sql
fsm_admin.merge_transition(
  p_ftr_fst_id => 'GRANT_MANUALLY',
  p_ftr_fev_id => 'GRANT',
  p_ftr_fcl_id => 'REQ',
  p_ftr_fst_list => 'GRANTED',
  p_ftr_raise_automatically => false,
  p_run_checks => false);

fsm_admin.merge_transition(
  p_ftr_fst_id => 'GRANTED',
  p_ftr_fev_id => 'NIL',
  p_ftr_fcl_id => 'REQ',
  p_ftr_fst_list => '',
  p_ftr_raise_automatically => false,
  p_run_checks => false);
```

Die vollständige Definition mit allen Genehmigungs- und Ablehnungspfaden liegt in `FSM/sample_app/scripts/create_fsm_data.sql`.

## Autoevents

Ein Autoevent ist deterministisch modelliert. Für jede Status-, Subklassen- und Ergebniskonstellation ist genau ein automatisches Ereignis festgelegt. Jede automatische Kette führt schließlich zu einem stabilen oder terminalen Status.

## Generierte Konstanten

`FSM_ADMIN.CREATE_STATUS_PACKAGE` und `FSM_ADMIN.CREATE_EVENT_PACKAGE` erzeugen `FSM_FST` und `FSM_FEV`. Implementierungen verwenden diese Konstanten anstelle freier Zeichenketten.
