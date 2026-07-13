# Installation und generierte Objekte

## Core-Installation

`FSM/core/install.sql` installiert in dieser Reihenfolge:

1. Meldungen
2. Sequenzen
3. Tabellen und Schemaanpassungen
4. Bereinigung generierter Objekte
5. Views
6. Type- und Package-Spezifikationen
7. Type- und Package-Bodies
8. Initialdaten und UTL_TEXT-Templates
9. Konstantenpackages `FSM_FST` und `FSM_FEV`
10. Package Body `FSM`

Die Reihenfolge berücksichtigt Abhängigkeiten zwischen Basistyp, generierten Konstanten und Package Body.

## Clientzugriff

`grant_client_access.sql` vergibt Leserechte auf öffentliche Views und Ausführungsrechte auf die vorgesehenen APIs. `register_client.sql` legt Synonyme im Client-Schema an.

## Sample-Anwendung

`FSM/sample_app/install_sample.sql` installiert die Beispielklasse `REQ` in dieser Reihenfolge:

1. fachliche Sequenz `FSM_REQUEST_SEQ`
2. Fachtabellen einschließlich `FSM_REQUESTS` mit `REQ_ID` und `REQ_FSM_ID`
3. `FSM_REQ_TYPE`
4. Status-, Ereignis- und Transitionsmetadaten
5. generierte Konstantenpackages
6. Views, `FSM_REQ` und `BL_REQUEST`
7. Type- und Package-Bodies

Die Sample-App dient als ausführbare Referenz für die Nutzung des Frameworks im eigenen Projekt.

## Natural Docs

Die generierte HTML-Dokumentation liegt in `Doc/index.html` und bildet die objektbezogene API-Referenz. Der Vault ergänzt sie um Zusammenhänge und Abläufe.
