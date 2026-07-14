# Ereignisbehandlung implementieren

Der konkrete SQL-Subtyp überschreibt `RAISE_EVENT` und delegiert an sein FSM-Package. Dort wird das Ereignis geprüft, die Fachaktion ausgeführt und der Zielstatus bestimmt.

## Verantwortlichkeiten

1. `FSM.ALLOWS_EVENT` prüft, ob das Ereignis im aktuellen Status erlaubt ist.
2. `FSM.RAISE_EVENT` sperrt die Instanz und setzt den gemeinsamen Ereigniskontext.
3. Das konkrete Package führt die zum Ereignis gehörende Fachlogik aus.
4. Der Handler bestimmt den Zielstatus.
5. `SET_STATUS` verarbeitet Persistenz, Logging, Lifecycle-Hooks und Folgeereignisse.

Den Laufzeitablauf erläutert [[02_Funktionen/Ereignisse-und-Statuswechsel|Ereignisse und Statuswechsel]].

## Zielstatus bestimmen

Lässt die Transition genau einen Zielstatus zu, kann der Handler `FSM.GET_NEXT_STATUS` verwenden. Gibt es mehrere zulässige Ergebnisse, entscheidet die Fachlogik und übergibt den gewählten Status ausdrücklich an `SET_STATUS`.

Freie Zeichenketten sollten vermieden werden. Nach der Metadateninstallation stehen die generierten Konstanten aus `FSM_FEV` und `FSM_FST` zur Verfügung.

## Ereignis- und Statuslogik trennen

Der Ereignishandler beantwortet die Frage, was das fachliche Kommando bewirkt und welcher Zielstatus daraus folgt. Wiederkehrendes Verhalten beim Verlassen oder Erreichen eines Status gehört dagegen in einen Lifecycle-Hook. Die Auswahlregel beschreibt [[03_FSM-verwenden/Lifecycle-Hooks-einsetzen|Lifecycle-Hooks einsetzen]].

## Laufzeitentscheidung begründen

Wählt die Fachlogik zwischen mehreren Zielstatus, hält `LOG_REASON` fest, warum diese konkrete Ausführung zu ihrem Ergebnis kam. Die Reason wird unmittelbar vor `SET_STATUS` gesetzt und vom nächsten erfolgreichen Statuslog übernommen.

Die Sample-App ergänzt die Entscheidung in `RAISE_CHECK` deshalb je Zweig:

```plsql
case l_mode
when bl_request.C_GRANT_AUTOMATICALLY then
  p_req.log_reason(
    p_reason_code => 'GRANT_AUTOMATICALLY',
    p_msg_args => msg_args(p_req.req_rtp_id, p_req.req_rre_id));
  l_new_status := fsm_fst.REQ_GRANT_AUTOMATICALLY;

when bl_request.C_GRANT_MANUALLY then
  p_req.log_reason(
    p_reason_code => 'GRANT_MANUALLY',
    p_msg_args => msg_args(p_req.req_rtp_id, p_req.req_rre_id));
  l_new_status := fsm_fst.REQ_GRANT_MANUALLY;
end case;

return p_req.set_status(l_new_status);
```

Für die Klasse `REQ` ergänzt FSM den Präfix `REQ_REASON_`. Aus `GRANT_MANUALLY` wird beispielsweise `REQ_REASON_GRANT_MANUALLY`. Die Argumente machen den Grund mit Antragstyp und Antragsteller konkret lesbar.

Transition-Reason und Runtime-Reason bilden gemeinsam die Story: Die Metadaten erklären, dass `CHECK` den Genehmigungsweg bestimmt; `LOG_REASON` erklärt, warum die aktuelle Anfrage automatisch, manuell oder durch einen Supervisor genehmigt werden muss. Details zu Speicherung und Auswertung enthält [[02_Funktionen/Transition-Reasons-und-Ausführungsstory|Transition-Reasons und Ausführungsstory]].

## Automatische Ereignisse

Autoevents verwenden dieselbe polymorphe `RAISE_EVENT`-Implementierung wie externe Ereignisse. Die Verarbeitung bleibt synchron: Jeder Handler setzt seinen Zielstatus, bis ein stabiler oder terminaler Status erreicht ist.

Die Metadaten dafür werden unter [[03_FSM-verwenden/Transitionen-und-Autoevents-definieren|Transitionen und Autoevents definieren]] eingerichtet.
