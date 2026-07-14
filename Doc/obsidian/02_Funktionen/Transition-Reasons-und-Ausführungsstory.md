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

## Einsatz in fachlicher Logik

Fachliche Implementierungen setzen `LOG_REASON` an der Stelle, an der die relevante Entscheidung getroffen wird. Geeignete Stellen sind insbesondere:

- ein überschriebener Event-Handler wie `RAISE_CHECK`
- ein Lifecycle-Hook vor oder nach einer Transition
- eine fachliche Entscheidungsmethode, die den Zielstatus auswählt

Beispiel:

```plsql
case bl_request.get_grant_mode(p_req_id => p_fsm_req.req_id)
  when bl_request.C_GRANT_AUTOMATICALLY then
    p_fsm_req.log_reason(
      p_reason_code => 'AUTO_GRANT_RULE_MATCHED',
      p_msg_args => msg_args('P_REQ_ID', p_fsm_req.req_id));

    l_fst_id := fsm_fst.REQ_GRANT_AUTOMATICALLY;

  when bl_request.C_GRANT_MANUALLY then
    p_fsm_req.log_reason(
      p_reason_code => 'MANUAL_GRANT_REQUIRED',
      p_msg_args => msg_args('P_REQ_ID', p_fsm_req.req_id));

    l_fst_id := fsm_fst.REQ_GRANT_MANUALLY;
end case;
```

Der anschließende Aufruf von `SET_STATUS` schreibt den Statuswechsel und übernimmt die gesetzte Reason in `FSM_LOG`.

## Praktische Regel

Die Transition-Reason gehört in die Metadaten, wenn sie den fachlichen Zweck eines Übergangs beschreibt. `LOG_REASON` gehört in die Fachlogik, wenn die Erklärung aus konkreten Laufzeitdaten oder aus einer Entscheidung der Fachlogik entsteht.
