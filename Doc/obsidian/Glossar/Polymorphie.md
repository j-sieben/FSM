# Polymorphie

Das Package `FSM` hält seine Instanz in einer Variablen vom Typ `FSM_TYPE` und ruft darauf beispielsweise `PERSIST_STATE` auf. Oracle führt dabei die `PERSIST_STATE`-Methode des konkreten abgeleiteten Typs aus. Derselbe Aufruf erreicht dadurch für jeden FSM-Typ die jeweils passende Implementierung. Dieses Verhalten heißt Polymorphie.

Siehe [[Glossar/Objekttyp|Objekttyp]] und [[Glossar/Lifecycle-Hook|Lifecycle-Hook]].
