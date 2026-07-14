# Initialstatus

Der Initialstatus ist der erste fachliche Status einer neuen FSM-Instanz. `FSM.INITIALIZE` ermittelt ihn aus den Metadaten für Klasse und Subklasse und setzt ihn über `SET_STATUS`. Dadurch werden Persistenz, Logging, Lifecycle-Hooks und automatische Folgeereignisse regulär ausgeführt.
