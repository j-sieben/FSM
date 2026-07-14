# Lifecycle-Hooks einsetzen

Lifecycle-Hooks binden Fachlogik an feste Stellen eines Statuswechsels. Eine Aktion wird danach eingeordnet, ob sie zum verlassenen oder erreichten Status, zum auslösenden Ereignis oder zur konkreten Persistenz gehört.

## Reihenfolge

Bei einem echten Statuswechsel läuft:

```text
FSM_OLD_FST_ID sichern und FSM_FST_ID auf den Zielstatus setzen
  -> LEAVE_STATUS
  -> BEFORE_TRANSITION
  -> gemeinsame FSM-Daten persistieren
  -> PERSIST_STATE
  -> Statuswechsel protokollieren
  -> ENTER_STATUS
  -> AFTER_TRANSITION
  -> Folgeereignisse beziehungsweise Autoevent verarbeiten
  -> COMMIT
```

Die vollständige Laufzeitsequenz zeigt [[01_Architektur/Laufzeit-und-Lifecycle#Zeitliche Abfolge|Laufzeit und Lifecycle]].

## Hook auswählen

| Hook | Bezug | Typischer Zweck |
| --- | --- | --- |
| `LEAVE_STATUS` | `FSM_OLD_FST_ID`, verlassener Status | Timer stoppen oder temporäre Ressourcen freigeben |
| `BEFORE_TRANSITION` | `FSM_FEV_ID`, Ereignis oder Übergang | ereignisabhängige Aktion vor der Persistenz |
| `PERSIST_STATE` | konkrete FSM-Instanz | fachliche Attribute und ID-Zuordnung speichern |
| `ENTER_STATUS` | `FSM_FST_ID`, erreichter Status | Verhalten des erfolgreich gespeicherten neuen Status starten |
| `AFTER_TRANSITION` | abgeschlossener Übergang | Nacharbeiten oder Propagation nach Persistenz und Logging |

`LEAVE_STATUS` und `ENTER_STATUS` gehören einem Status. `BEFORE_TRANSITION` und `AFTER_TRANSITION` gehören dem Ereignis beziehungsweise Übergang.

## Feldbelegung in `LEAVE_STATUS`

Vor `LEAVE_STATUS` kopiert der Laufzeitkern den bisherigen Status nach `FSM_OLD_FST_ID` und setzt `FSM_FST_ID` bereits auf den Zielstatus. Beim Wechsel `ORDERED` nach `RUNNING` gilt daher:

```text
FSM_OLD_FST_ID = ORDERED
FSM_FST_ID     = RUNNING
```

`RUNNING` ist zu diesem Zeitpunkt noch nicht persistiert oder protokolliert. Eine Exit-Aktion für `ORDERED` prüft `FSM_OLD_FST_ID`. Erst `ENTER_STATUS` meldet nach Persistenz und Logging den erfolgreichen Eintritt in `RUNNING`.

## Status-Hooks

Eine Aktion gehört in `LEAVE_STATUS` oder `ENTER_STATUS`, wenn sie unabhängig vom auslösenden Ereignis immer beim Verlassen beziehungsweise Erreichen des betreffenden Status erforderlich ist.

- `LEAVE_STATUS` bei `FSM_OLD_FST_ID = RUNNING`: Timer stoppen und Ressourcen des laufenden Zustands freigeben.
- `ENTER_STATUS` bei `FSM_FST_ID = VALIDATING`: den zum erreichten Status gehörenden Validierungsprozess starten.
- `ENTER_STATUS` bei einem Terminalstatus: den fachlichen Abschluss ausführen.

Bei der Initialisierung entfällt `LEAVE_STATUS`, weil kein alter Status existiert. `ENTER_STATUS` wird für den Initialstatus ausgeführt. Bei einer Selbsttransition entfallen beide Status-Hooks.

## Transition-Hooks

Eine Aktion gehört in `BEFORE_TRANSITION` oder `AFTER_TRANSITION`, wenn sie vom fachlichen Kommando abhängt oder auch bei einer Selbsttransition ausgeführt werden muss.

- `BEFORE_TRANSITION` bei Ereignis `VALIDATE`: die durch dieses Kommando ausgelöste Validierung beauftragen.
- `BEFORE_TRANSITION` bei Ereignis `ORDER_COPY`: den Kopierauftrag vor der Persistenz starten.
- `AFTER_TRANSITION`: abhängige Objekte erst nach erfolgreicher Persistenz und Protokollierung informieren.

Bei einer Selbsttransition lautet der verkürzte Ablauf:

```text
BEFORE_TRANSITION
  -> PERSIST_STATE
  -> Logging
  -> AFTER_TRANSITION
```

## Doppelungen vermeiden

Eine Fachaktion gehört genau zu einer Bedeutung. Wird eine Validierung sowohl durch `BEFORE_TRANSITION(VALIDATE)` als auch durch `ENTER_STATUS(VALIDATING)` gestartet, läuft sie doppelt.

Die fachliche Formulierung hilft bei der Zuordnung:

- „Das Ereignis `VALIDATE` wurde beauftragt“: `BEFORE_TRANSITION`.
- „Der Status `VALIDATING` wurde erfolgreich erreicht“: `ENTER_STATUS`.
- „Die Wirkung darf erst nach erfolgreicher Speicherung weitergegeben werden“: `AFTER_TRANSITION`.
- „Der bisherige Status `RUNNING` wird verlassen“: `LEAVE_STATUS`.

Statusprüfungen in Transition-Hooks und Ereignisprüfungen in Status-Hooks sollten begründete Ausnahmen bleiben.
