---
tags:
  - fsm
  - integration
  - plsql
---

# FSM im eigenen Projekt verwenden

Dieser Bereich beschreibt, wie ein eigenes PL/SQL-Projekt das FSM-Framework für seine Fachobjekte einsetzt. Das Framework stellt Laufzeitsteuerung, Persistenz der gemeinsamen FSM-Daten, Logging, Autoevents und Lifecycle bereit. Das Projekt ergänzt die konkrete Beschreibung seines Prozesses und verbindet die FSM mit seinen fachlichen Packages und Tabellen.

Für eine konkrete Nutzung werden drei Bausteine erstellt:

1. Ein eigener, von `FSM_TYPE` abgeleiteter Objekttyp repräsentiert die FSM-Instanz des Fachobjekts und verbindet die zentralen Methoden mit den Packages des Projekts.
2. Ein konkretes FSM-Package implementiert Konstruktoren, Ereignisverteilung, fachliche Persistenz und die Verbindung zur fachlichen ID.
3. Projektbezogene Metadaten beschreiben Status, Ereignisse und Transitionen des fachlichen Lebenszyklus.

Die folgenden Dokumente führen durch diese Aufgaben:

- [[03_FSM-verwenden/Eigene-FSM-implementieren|Eigene FSM implementieren]] beschreibt Objekttyp, Type Body, Konstruktoren, Ereignisbehandlung und Lifecycle-Hooks.
- [[03_FSM-verwenden/Metadaten-definieren|Metadaten definieren]] beschreibt die Registrierung des fachlichen Zustandsgraphen und die Erzeugung der Konstantenpackages.
- [[02_Funktionen/Instanzen-erstellen-und-laden|Instanzen erstellen und laden]] erläutert die Zuordnung zwischen `FSM_ID` und fachlicher ID.

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

Der Ablauf beginnt bei einer neuen `REQ_ID`. `FSM.INITIALIZE` ergänzt die `FSM_ID`; `PERSIST_STATE` speichert beide IDs in `FSM_REQUESTS`. Das automatische Ereignis `INITIALIZE` führt von `CREATED` nach `IN_PROCESS`. Dort entscheidet `CHECK`, welcher Genehmigungspfad folgt. `GRANTED` und `REJECTED` schließen den Prozess fachlich ab.

Die Implementierung verteilt sich auf folgende Verzeichnisse:

- `FSM/sample_app/types` – konkreter Objekttyp
- `FSM/sample_app/packages` – FSM- und Fachpackages
- `FSM/sample_app/tables` und `FSM/sample_app/views` – fachliche Persistenz und gemeinsame Ladesicht
- `FSM/sample_app/scripts/create_fsm_data.sql` – Klasse, Status, Ereignisse und Transitionen
