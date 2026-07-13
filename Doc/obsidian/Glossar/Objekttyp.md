# Objekttyp

Ein Oracle-Objekttyp definiert einen eigenen Datentyp mit Attributen und Methoden. Ein mit `UNDER` abgeleiteter Typ übernimmt diese Attribute und Methoden und kann weitere hinzufügen. Mit `OVERRIDING` passt er eine geerbte Methode an seine Aufgabe an.

Im Framework stellt `FSM_TYPE` die gemeinsamen Daten und Methoden aller FSM-Instanzen bereit. Die konkreten Typen ergänzen ihre fachlichen Daten sowie die Verarbeitung ihrer Ereignisse.

Siehe [[00_Start/Einführung-in-Finite-State-Machines|Einführung in Finite State Machines]].
