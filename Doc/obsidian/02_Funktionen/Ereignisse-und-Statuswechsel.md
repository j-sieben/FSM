# Ereignisse und Statuswechsel

## Ereignis auslösen

Der konkrete Subtyp überschreibt `RAISE_EVENT` und delegiert an sein Package. Dort wird zunächst mit `FSM.ALLOWS_EVENT` geprüft, ob das Ereignis in der aktuellen Ereignisliste enthalten ist.

Der generische Aufruf `FSM.RAISE_EVENT` sperrt die Instanz, merkt sich Quellstatus und Ereignis und erzeugt den Ereignislog. Danach führt das konkrete Package die fachliche Aktion aus und bestimmt den Zielstatus.

## Zielstatus bestimmen

Wenn eine Transition genau einen Zielstatus zulässt, kann der Handler `FSM.GET_NEXT_STATUS` verwenden. Bei mehreren zulässigen Ergebnissen entscheidet die Fachlogik und übergibt den Zielstatus direkt an `SET_STATUS`.

## Status setzen

`SET_STATUS` führt den in [[01_Architektur/Laufzeit-und-Lifecycle|Laufzeit und Lifecycle]] beschriebenen Ablauf aus. Die Liste der nächsten Ereignisse wird aus `BL_FSM_ACTIVE_STATUS_EVENT` ermittelt und in der Instanz sowie in `FSM_OBJECTS` gespeichert.

## Automatische Ereignisse

Ist das Folgeereignis als automatisch markiert, ruft `SET_STATUS` polymorph `p_fsm.raise_event(...)` auf. Der konkrete Handler setzt wiederum einen Status. Dadurch entsteht eine synchrone Rekursion bis zu einem stabilen oder terminalen Status.

Metadaten müssen pro Status-, Subklassen- und Ergebnisstatuskombination höchstens ein Autoevent definieren. `FSM_ADMIN` prüft diese Eindeutigkeit.

## Terminaler Status

Wenn die Ereignisliste `NIL` enthält, wird die Instanz finalisiert. Das konkrete Verhalten kann über `FINALIZE` beziehungsweise vorgelagerte Lifecycle-Hooks ergänzt werden.
