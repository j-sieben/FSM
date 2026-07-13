# Logging, Fehler und Retry

## Logging

`FSM_LOG` enthält Ereignis- und Statuschronik. Ein Eintrag kann enthalten:

- aktuelle und vorherige Status-ID
- auslösendes Ereignis
- Liste der erlaubten Folgeereignisse
- PIT-Meldung und Meldungsargumente
- statischen Übergangsgrund aus den Metadaten
- dynamischen Laufzeitgrund aus `LOG_REASON`

`LOG_REASON` legt den Grund zunächst im instanzbezogenen Package-Kontext ab. Der nächste erfolgreiche Statuslog übernimmt ihn und leert den Kontext.

## Fehlerbehandlung

Fehler in `SET_STATUS` werden an einen kontrollierten Fehlerpfad übergeben. Der erste technische Fehler ist für die Diagnose maßgeblich und bleibt als Hauptursache erhalten. Weitere Fehler aus dem anschließenden Fallback werden als Folgefehler behandelt.

Für die Analyse ist die Reihenfolge wichtig:

1. erster Fehler in Handler, Persistenz oder Logging
2. Aufruf des Fehlerpfads
3. möglicher Folgefehler beim Setzen des Fehlerstatus

## Retry

Retryparameter liegen am Status. Bei einem fehlgeschlagenen Ereignis speichert der Laufzeitkern Ereignis, Gültigkeit und Retryplanung in `FSM_OBJECTS`. Die aktuelle Ausführung wartet und wiederholt synchron. Die Persistenz der Retrydaten erfolgt in autonomen Transaktionen, damit der Retryzustand auch bei einem Rollback des Hauptpfads erhalten bleibt.

## Letzter Fehlerfallback

`FORCE_ERROR_STATUS` versetzt die Instanz auf einem technischen Sicherungspfad direkt in einen Fehlerzustand. Die reguläre Modellierung stellt zusätzlich einen gültigen Fehlerstatus pro Klasse bereit.
