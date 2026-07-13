# Diagnoseleitfaden

## Statusobjekt bei leerem FSM-Log

Prüfreihenfolge:

1. Aufruf von `FSM.PERSIST` innerhalb `FSM.SET_STATUS`
2. Aufruf von `PERSIST_STATE` für den konkreten Laufzeittyp
3. erfolgreicher Abschluss von `FSM.LOG_CHANGE`
4. Commit-Verantwortung des Laufzeitkerns
5. erster Fehler aus Error Stack und Backtrace

## Ausführung eines Autoevents prüfen

Prüfen:

- `FSM_FEV_LIST` nach dem Zielstatus
- `FSM_AUTO_RAISE`
- aktive Transition in `BL_FSM_ACTIVE_STATUS_EVENT`
- Rückgabewert des konkreten `RAISE_EVENT`
- nachfolgender Aufruf von `SET_STATUS`

Der erste Fehler in Persistenz oder Logging bestimmt den Abbruchpunkt vor dem Autoevent-Block. Ein späterer Fehlerstatus oder Constraintfehler wird als Folgefehler eingeordnet.

## Erstell- und Ladepfad des Konstruktors unterscheiden

Der fachliche Konstruktor unterscheidet anhand einer vorhandenen `FSM_ID`. Eine fachliche View-Zeile mit `FSM_ID` repräsentiert eine persistierte FSM-Instanz; die übrigen Zeilen führen in den Erstellungspfad.

## PIT-Trace lesen

Der Call Stack zeigt die aufgerufenen Methoden. Ein Fehler in `PIT.ENTER_*` kann dabei vor dem Schreiben des eingerückten Traceeintrags auftreten. Bei mehreren Fehlern ist der erste Error Stack beziehungsweise Backtrace maßgeblich.
