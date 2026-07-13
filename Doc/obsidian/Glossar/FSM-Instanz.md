# FSM-Instanz

Eine FSM-Instanz begleitet den Lebenszyklus eines konkreten Fachobjekts. Sie besitzt eine technische `FSM_ID`, Klasse, Subklasse, aktuellen Status, Ergebniszustand und erlaubte Folgeereignisse. Eine Referenz auf die fachliche ID stellt die Verbindung zum Fachobjekt her. Gemeinsame FSM-Werte liegen in `FSM_OBJECTS`; die fachlichen Werte bleiben in den anwendungseigenen Tabellen.

In der Sample-App enthält `FSM_REQ_TYPE` dazu die fachliche `REQ_ID`; `FSM_REQUESTS.REQ_FSM_ID` verbindet sie mit der technischen `FSM_ID`.
