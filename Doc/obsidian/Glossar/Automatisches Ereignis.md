# Automatisches Ereignis

Ein automatisches Ereignis wird nach erfolgreichem Eintritt in einen Status durch den Laufzeitkern ausgelöst. `FSM.SET_STATUS` führt es synchron aus. Entsteht daraus erneut ein Autoevent, wird die Kette rekursiv fortgesetzt, bis ein stabiler oder terminaler Status erreicht ist.
