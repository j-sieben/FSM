# Transition-Reasons und Ausführungsstory

`FSM_LOG` beschreibt die Bewegung einer FSM-Instanz als fachlich lesbare Ausführungsstory. Ein Logeintrag enthält deshalb neben Status, Ereignis und Meldung auch Gründe. FSM unterscheidet dabei zwei Arten von Gründen:

- die statische Transition-Reason aus dem [[Glossar/Metadatenmodell|Metadatenmodell]]
- die dynamische Runtime-Reason aus der konkreten Ausführung

Beide Informationen ergänzen sich. Die Transition-Reason erklärt, welche fachliche Regel hinter dem modellierten Übergang steht. Die Runtime-Reason erklärt, welche konkrete Entscheidung oder Laufzeitbedingung bei dieser Ausführung relevant war.

## Transition-Reason

Eine [[Glossar/Transition|Transition]] kann über `FTR_REASON_MSG_ID` eine PIT-Meldung als Übergangsgrund hinterlegen. Diese Reason gehört zur Definition des Zustandsgraphen.

Beispiel:

```sql
fsm_admin.merge_transition(
  p_ftr_fst_id => 'IN_PROCESS',
  p_ftr_fev_id => 'CHECK',
  p_ftr_fcl_id => 'REQ',
  p_ftr_fst_list => 'GRANT_AUTOMATICALLY:GRANT_MANUALLY:GRANT_SUPERVISOR',
  p_ftr_raise_automatically => true,
  p_ftr_reason_msg_id => 'REQ_REASON_CHECK_REQUEST');
```

Diese Angabe beschreibt den fachlichen Sinn der Transition: Ein Antrag im Status `IN_PROCESS` wird durch `CHECK` geprüft und kann danach in einen der erlaubten Ergebnisstatus wechseln.

Beim Schreiben des Logeintrags ermittelt FSM die passende Transition-Reason anhand von:

- vorherigem Status
- auslösendem Ereignis
- Zielstatus
- FSM-Klasse und Subklasse

Die ermittelte PIT-Meldung wird in `FSM_LOG.FSL_TRANSITION_REASON_MSG_ID` gespeichert.

## Runtime-Reason

Die Runtime-Reason entsteht während der Ausführung. Sie wird über die Reason-Schnittstelle der FSM-Instanz gesetzt:

```plsql
p_fsm_req.log_reason(
  p_reason_code => 'AUTO_GRANT_LIMIT_MATCHED',
  p_msg_args => msg_args('P_AMOUNT', l_amount));
```

`LOG_REASON` speichert den Grund zunächst im instanzbezogenen Laufzeitkontext. Der nächste erfolgreiche Statuslog übernimmt diesen Kontext nach `FSM_LOG`:

- `FSL_REASON_MSG_ID`
- `FSL_REASON_MSG_ARGS`

Wenn der übergebene Reason-Code den Klassenpräfix enthält, verwendet FSM ihn direkt. Andernfalls ergänzt FSM den Präfix aus der Klasse. Aus `AUTO_GRANT_LIMIT_MATCHED` wird bei der Klasse `REQ` die Meldungs-ID `REQ_REASON_AUTO_GRANT_LIMIT_MATCHED`.

Für eine bereits vollständig aufgelöste PIT-Message steht eine zweite Überladung zur Verfügung:

```plsql
p_fsm.log_reason(
  p_reason => pit.get_message(
    p_message_name => 'INREST_UNKNOWN_ENDPOINT',
    p_msg_args => msg_args(l_endpoint)));
```

Diese Variante übernimmt `MESSAGE_NAME` und `MESSAGE_ARGS` unverändert. Insbesondere ergänzt sie keinen Klassenpräfix; eine vollständig qualifizierte Meldung einer anderen Message-Gruppe wie `INREST_UNKNOWN_ENDPOINT` bleibt deshalb erhalten. Die String-Überladung bleibt für klassenspezifische Reason-Codes zuständig und verwendet weiterhin `<FSM-Klasse>_REASON_`.

Die Runtime-Reason gilt für den nächsten erfolgreichen Logeintrag. Danach leert FSM den Kontext. Dadurch bleibt die Reason eindeutig einem konkreten Statuswechsel zugeordnet.

## Ausführungsstory in FSM_LOG

Eine Ausführungsstory entsteht aus der Kombination der technischen Bewegung und der beiden Begründungsebenen.

| Ebene | Quelle | Spalte in `FSM_LOG` | Aussage |
| --- | --- | --- | --- |
| Bewegung | FSM-Laufzeit | `FSL_PREV_FST_ID`, `FSL_FST_ID`, `FSL_FEV_ID` | Von welchem Status durch welches Ereignis in welchen Status gewechselt wurde |
| Meldung | PIT-Meldung des Ereignisses oder Status | `FSL_MSG_ID`, `FSL_MSG_TEXT`, `FSL_MSG_ARGS` | Welche protokollierte Meldung zur Bewegung gehört |
| Transition-Reason | Metadaten der Transition | `FSL_TRANSITION_REASON_MSG_ID` | Welche fachliche Regel den Übergang beschreibt |
| Runtime-Reason | `LOG_REASON` während der Ausführung | `FSL_REASON_MSG_ID`, `FSL_REASON_MSG_ARGS` | Welche konkrete Entscheidung oder Laufzeitbedingung diese Ausführung erklärt |

Damit beantwortet ein Logeintrag mehrere Fragen gleichzeitig:

- Was ist passiert?
- Welcher Status war vorher erreicht?
- Welcher Status wurde danach erreicht?
- Welches Ereignis hat den Wechsel ausgelöst?
- Welche fachliche Regel beschreibt diesen Übergang?
- Welche konkrete Entscheidung wurde in dieser Ausführung getroffen?

## Durchgängiges Beispiel der Sample-App

Die Sample-App verwendet beide Gründe für den Übergang `IN_PROCESS + CHECK`:

- Die Transition hinterlegt `REQ_REASON_CHECK_REQUEST`. Sie erklärt dauerhaft, dass `CHECK` den erforderlichen Genehmigungsweg bestimmt.
- `FSM_REQ.RAISE_CHECK` ermittelt anhand von Antragstyp und Antragsteller den konkreten Weg.
- Direkt vor `SET_STATUS` setzt der gewählte Zweig eine Runtime-Reason wie `GRANT_AUTOMATICALLY`, `GRANT_MANUALLY` oder `GRANT_SUPERVISOR`.
- FSM ergänzt den Klassenpräfix und schreibt beispielsweise `REQ_REASON_GRANT_MANUALLY` mit Antragstyp und Antragsteller in den nächsten Statuslog.

Der manuelle Zweig ist im Handler so implementiert:

```plsql
when bl_request.C_GRANT_MANUALLY then
  p_req.log_reason(
    p_reason_code => 'GRANT_MANUALLY',
    p_msg_args => msg_args(p_req.req_rtp_id, p_req.req_rre_id));
  l_new_status := fsm_fst.REQ_GRANT_MANUALLY;
end case;

return p_req.set_status(l_new_status);
```

Der resultierende Story-Eintrag beantwortet damit getrennt:

| Frage | Wert im Beispiel |
| --- | --- |
| Was geschah? | `IN_PROCESS` wechselte durch `CHECK` nach `GRANT_MANUALLY` |
| Warum existiert dieser Übergang? | Der Antrag wird geprüft, um den erforderlichen Genehmigungsweg zu bestimmen |
| Warum wurde dieser Zielstatus gewählt? | Der konkrete Antragstyp erfordert für den Antragsteller eine manuelle Genehmigung |

Eine Runtime-Reason wird an der fachlichen Entscheidungsstelle gesetzt. Das kann ein Event-Handler, ein Lifecycle-Hook oder eine aufgerufene Entscheidungsmethode sein. Entscheidend ist, dass `LOG_REASON` vor dem zugehörigen `SET_STATUS` ausgeführt wird.

## Praktische Regel

Die Transition-Reason gehört in die Metadaten, wenn sie den fachlichen Zweck eines Übergangs beschreibt. `LOG_REASON` gehört in die Fachlogik, wenn die Erklärung aus konkreten Laufzeitdaten oder aus einer Entscheidung der Fachlogik entsteht.
