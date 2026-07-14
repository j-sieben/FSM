# Transitionen und Autoevents definieren

Eine Transition verbindet Quellstatus und Ereignis mit einer Liste zulässiger Zielstatus. Sie kann zusätzlich automatische Auslösung, Rollen, Ergebniswerte und einen statischen Übergangsgrund festlegen.

## Transition registrieren

Eine Transition mit genau einem Zielstatus kann vollständig durch die Metadaten aufgelöst werden:

```sql
fsm_admin.merge_transition(
  p_ftr_fst_id => 'CREATED',
  p_ftr_fev_id => 'INITIALIZE',
  p_ftr_fcl_id => 'REQ',
  p_ftr_fst_list => 'IN_PROCESS',
  p_ftr_raise_automatically => true,
  p_run_checks => false);
```

Enthält `FTR_FST_LIST` mehrere Zielstatus, wählt die Fachlogik im Ereignishandler das konkrete Ergebnis:

```sql
fsm_admin.merge_transition(
  p_ftr_fst_id => 'IN_PROCESS',
  p_ftr_fev_id => 'CHECK',
  p_ftr_fcl_id => 'REQ',
  p_ftr_fst_list =>
    'GRANT_AUTOMATICALLY:GRANT_MANUALLY:GRANT_SUPERVISOR',
  p_ftr_raise_automatically => true,
  p_run_checks => false);
```

Die Implementierung des Handlers beschreibt [[03_FSM-verwenden/Ereignisbehandlung-implementieren|Ereignisbehandlung implementieren]].

## Fachlichen Übergangsgrund hinterlegen

`FTR_REASON_MSG_ID` beschreibt als [[02_Funktionen/Transition-Reasons-und-Ausführungsstory#Transition-Reason|Transition-Reason]], warum der modellierte Übergang fachlich existiert. Dieser statische Grund gilt für jede Ausführung der Transition.

Die Sample-App erklärt damit, warum `CHECK` einen Antrag von `IN_PROCESS` in einen der möglichen Genehmigungswege führt:

```sql
fsm_admin.merge_transition(
  p_ftr_fst_id => 'IN_PROCESS',
  p_ftr_fev_id => 'CHECK',
  p_ftr_fcl_id => 'REQ',
  p_ftr_fst_list =>
    'GRANT_AUTOMATICALLY:GRANT_MANUALLY:GRANT_SUPERVISOR',
  p_ftr_raise_automatically => true,
  p_ftr_reason_msg_id => 'REQ_REASON_CHECK_REQUEST',
  p_run_checks => false);
```

Die Meldung sagt sinngemäß: Der Antrag wird geprüft, um den erforderlichen Genehmigungsweg zu bestimmen. Sie erklärt die fachliche Regel, aber noch nicht, warum bei einer konkreten Anfrage genau ein bestimmter Zielstatus gewählt wurde. Diese zweite Ebene setzt der Ereignishandler mit `LOG_REASON`.

## Autoevents modellieren

Ein Autoevent wird unmittelbar nach dem vorherigen Übergang auf derselben Instanz ausgelöst. Die Kette läuft synchron, bis ein stabiler oder terminaler Status erreicht ist.

Für jede Kombination aus Status, Klasse, Subklasse und Ergebnis darf höchstens ein Autoevent wirksam sein. Jede automatische Kette muss einen stabilen oder terminalen Endpunkt besitzen.

## Terminalpfad abschließen

Ein Übergang auf das technische Ereignis `NIL` markiert das Ende des Graphen:

```sql
fsm_admin.merge_transition(
  p_ftr_fst_id => 'GRANTED',
  p_ftr_fev_id => 'NIL',
  p_ftr_fcl_id => 'REQ',
  p_ftr_fst_list => '',
  p_ftr_raise_automatically => false,
  p_run_checks => false);
```

Nach dem Eintritt in den terminalen Status erkennt der Laufzeitkern `NIL` und ruft `FINALIZE` auf.

## Metadaten prüfen

Nach dem Anlegen des vollständigen Graphen prüft `FSM_ADMIN` unter anderem Initialstatus, verwendete Ereignisse, erreichbare Zielstatus und eindeutige Autoevents. Erst danach werden die Konstantenpackages erzeugt.

Die vollständige Definition der Sample-App liegt in `FSM/sample_app/scripts/create_fsm_data.sql`.
