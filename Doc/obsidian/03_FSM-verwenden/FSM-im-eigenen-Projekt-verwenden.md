---
tags:
  - fsm
  - integration
  - plsql
---

# FSM im eigenen Projekt verwenden

Dieser Bereich ist die Arbeitsanleitung für die Integration des FSM-Frameworks in ein PL/SQL-Projekt. Das Framework stellt Laufzeitsteuerung, gemeinsame Persistenz, Logging, Autoevents und Lifecycle bereit. Das Projekt ergänzt den konkreten Objekttyp, seine Fachlogik und den Zustandsgraphen.

## Empfohlene Reihenfolge

1. [[03_FSM-verwenden/Fachobjekt-und-FSM-verbinden|Fachobjekt und FSM verbinden]] – SQL-Subtyp, fachliche ID, `FSM_ID`, Konstruktoren und Persistenz anlegen.
2. [[03_FSM-verwenden/Ereignisbehandlung-implementieren|Ereignisbehandlung implementieren]] – Ereignisse prüfen, Fachlogik ausführen und Zielstatus bestimmen.
3. [[03_FSM-verwenden/Lifecycle-Hooks-einsetzen|Lifecycle-Hooks einsetzen]] – Fachaktionen eindeutig einem Status oder Übergang zuordnen.
4. [[03_FSM-verwenden/Klasse-Status-und-Ereignisse-definieren|Klasse, Status und Ereignisse definieren]] – die Knoten und Ereignisse des Zustandsgraphen registrieren.
5. [[03_FSM-verwenden/Transitionen-und-Autoevents-definieren|Transitionen und Autoevents definieren]] – erlaubte Übergänge und automatische Verarbeitung modellieren.

Die Notizen unter `02_Funktionen` erklären das Verhalten des Frameworks. Die Notizen in diesem Bereich beschreiben dagegen die konkreten Implementierungsaufgaben eines verwendenden Projekts.

## Durchgängiges Beispiel der Sample-App

`FSM/sample_app` zeigt diese Integration anhand einer Berechtigungsanfrage:

| Baustein | Sample-Implementierung |
| --- | --- |
| fachliche ID und Fachdaten | `FSM_REQUESTS.REQ_ID`, Request-Typ, Antragsteller und Antragstext |
| technische Zuordnung | `FSM_REQUESTS.REQ_FSM_ID` verweist auf `FSM_OBJECTS.FSM_ID` |
| konkreter Objekttyp | `FSM_REQ_TYPE` mit Konstruktoren, `RAISE_EVENT` und `PERSIST_STATE` |
| konkretes FSM-Package | `FSM_REQ` verteilt Ereignisse und delegiert Fachentscheidungen |
| fachliches Package | `BL_REQUEST` persistiert Anfragen und bestimmt den Genehmigungsmodus |
| Metadaten | Klasse `REQ` mit Initialstatus `CREATED` und den Terminalstatuswerten `GRANTED` und `REJECTED` |

Der Ablauf beginnt bei einer neuen `REQ_ID`. `FSM.INITIALIZE` ergänzt die `FSM_ID`; `PERSIST_STATE` speichert beide IDs in `FSM_REQUESTS`. Das automatische Ereignis `INITIALIZE` führt von `CREATED` nach `IN_PROCESS`. Dort entscheidet `CHECK`, welcher Genehmigungspfad folgt. Die Transition-Reason erklärt den Zweck dieser Prüfung; `LOG_REASON` dokumentiert, warum die konkrete Anfrage automatisch, manuell oder durch einen Supervisor genehmigt werden muss. `GRANTED` und `REJECTED` schließen den Prozess fachlich ab.

Wie daraus eine fachlich lesbare Story in `FSM_LOG` entsteht, beschreibt [[02_Funktionen/Transition-Reasons-und-Ausführungsstory|Transition-Reasons und Ausführungsstory]].

Die Referenzimplementierung verteilt sich auf folgende Verzeichnisse:

- `FSM/sample_app/types` – konkreter Objekttyp
- `FSM/sample_app/packages` – FSM- und Fachpackages
- `FSM/sample_app/tables` und `FSM/sample_app/views` – fachliche Persistenz und gemeinsame Ladesicht
- `FSM/sample_app/scripts/create_fsm_data.sql` – Klasse, Status, Ereignisse und Transitionen
