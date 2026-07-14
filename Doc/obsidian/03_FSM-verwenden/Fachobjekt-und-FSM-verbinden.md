# Fachobjekt und FSM verbinden

Ein konkreter, von `FSM_TYPE` abgeleiteter SQL-Objekttyp verbindet die technische FSM-Instanz mit dem Fachobjekt des Projekts. Er hält mindestens die fachliche ID und erbt `FSM_ID`, Status, Ereigniskontext und Laufzeitmethoden vom Framework.

## Identitäten zuordnen

Die technische `FSM_ID` identifiziert den Datensatz in `FSM_OBJECTS`. Eine fachliche ID identifiziert beispielsweise eine Anfrage, einen Auftrag oder ein Gerät. Eine Fachtabelle oder Zuordnungstabelle speichert beide IDs und verbindet sie eindeutig.

In der Sample-App ist `REQ_ID` der fachliche Schlüssel. `REQ_FSM_ID` verweist auf `FSM_OBJECTS.FSM_ID`. Das vollständige Erstellungs- und Lademodell beschreibt [[02_Funktionen/Instanzen-erstellen-und-laden|Instanzen erstellen und laden]].

## Konkreten Subtyp definieren

`FSM_REQ_TYPE` ergänzt die für die Anfrage benötigten Attribute und überschreibt nur die Methoden, die das Projekt tatsächlich implementiert:

```sql
create or replace type fsm_req_type under fsm_type(
  req_id number,
  req_rtp_id varchar2(50 char),
  req_rre_id varchar2(50 char),
  req_text varchar2(1000 char),
  constructor function fsm_req_type(
    self in out nocopy fsm_req_type,
    p_fsm_id in number)
    return self as result,
  overriding member function raise_event(
    self in out nocopy fsm_req_type,
    p_fev_id in varchar2,
    p_msg in varchar2 default null,
    p_msg_args in msg_args default null)
    return number,
  overriding member procedure persist_state(
    self in out nocopy fsm_req_type)
);
/
```

Der Type Body bleibt eine dünne, statisch kompilierte Verbindungsschicht. SQL, Prüfungen und umfangreiche Fachlogik gehören in Packages.

## Konstruktoren implementieren

Der Neu-Konstruktor setzt Klasse, Subklasse, fachliche ID und weitere konkrete Attribute, bevor er `FSM.INITIALIZE` aufruft. Das Framework ermittelt anschließend den Initialstatus und verarbeitet mögliche Autoevents vollständig vor der Rückkehr.

Der Lade-Konstruktor übernimmt den vorhandenen Zustand aus einer gemeinsamen View in den konkreten Objekttyp. Er initialisiert keinen neuen Lifecycle und erzeugt keine zusätzlichen Logeinträge.

## Konkrete Daten persistieren

`PERSIST_STATE` wird innerhalb der vom FSM-Kern kontrollierten Transaktion aufgerufen. Die Objektmethode delegiert an das konkrete Package:

```sql
overriding member procedure persist_state(
  self in out nocopy fsm_req_type)
as
begin
  fsm_req.set_status(self);
end persist_state;
```

Das konkrete Package speichert die Zuordnung von fachlicher ID und `FSM_ID` sowie weitere Fachdaten. Es führt keinen eigenen Commit aus.

## Referenzimplementierung

- `FSM/sample_app/types/fsm_req_type.tps`
- `FSM/sample_app/types/fsm_req_type.tpb`
- `FSM/sample_app/packages/fsm_req.pks`
- `FSM/sample_app/packages/fsm_req.pkb`
- `FSM/sample_app/packages/bl_request.pks`
- `FSM/sample_app/packages/bl_request.pkb`
