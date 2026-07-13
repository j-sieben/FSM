# Initialstatus

Der Initialstatus ist der erste fachliche Status einer neuen FSM-Instanz. Der Neu-Konstruktor setzt ihn über `SET_STATUS`, damit Persistenz, Logging, Lifecycle-Hooks und automatische Folgeereignisse regulär ausgeführt werden.
