# Eskalation und Aktivität

Status können Warn- und Alarmintervalle definieren:

- `FST_WARN_INTERVAL`
- `FST_ALERT_INTERVAL`

`FST_ESCALATION_BASIS` bestimmt die zeitliche Grundlage:

| Wert | Grundlage |
| --- | --- |
| `STATUS` | Zeitpunkt des letzten tatsächlichen Statuswechsels |
| `EVENT` | Zeitpunkt der letzten Aktivität beziehungsweise des letzten Ereignisses |

`FSM_OBJECTS` hält dafür zwei Zeitpunkte:

- `FSM_STATUS_CHANGE_DATE`
- `FSM_LAST_CHANGE_DATE`

Wiederholte Fortschrittsereignisse zeigen so Aktivität bei gleichbleibendem Status an. `FSM_OBJECTS_V` leitet daraus den Zustand `OK`, `WARN` oder `ALERT` ab.

Diese Trennung beantwortet zwei verschiedene Fragen:

- Wie lange befindet sich die Instanz bereits in diesem Status?
- Wie viel Zeit ist seit der letzten Aktivität innerhalb dieses Status vergangen?
