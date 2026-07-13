# Eigene FSM implementieren

## Aufgabe des eigenen FSM-Typs

Der eigene FSM-Typ repräsentiert im PL/SQL-Code die FSM-Instanz eines konkreten Fachobjekts. Er führt die gemeinsamen FSM-Daten und Methoden aus `FSM_TYPE` mit den projektspezifischen Angaben zusammen. Dazu gehören vor allem die fachliche ID und gegebenenfalls weitere Werte, die während eines Ereignisses oder Statuswechsels benötigt werden.

Der Laufzeitkern arbeitet für alle Projekte mit `FSM_TYPE` und ruft darauf Methoden wie `SET_STATUS`, `RAISE_EVENT` oder `PERSIST_STATE` auf. Der abgeleitete Typ stellt für diese Aufrufe die Verbindung zum eigenen Projekt her. Seine überschriebenen Methoden delegieren direkt an das konkrete FSM-Package und von dort an die fachlichen Packages.

Der Typ erfüllt damit drei praktische Aufgaben:

- Er hält die technische `FSM_ID`, den aktuellen Status und die fachliche ID gemeinsam in einer Instanz bereit.
- Er übernimmt die vollständige allgemeine FSM-Funktionalität durch Vererbung von `FSM_TYPE`.
- Er verbindet die vorgesehenen Lifecycle- und Ereignismethoden über statisch kompilierte PL/SQL-Aufrufe mit der Fachlogik des Projekts.

Eine Instanz dieses Typs begleitet jeweils ein Fachobjekt durch dessen Lebenszyklus. Die Zuordnungstabelle verbindet ihre `FSM_ID` dauerhaft mit der fachlichen ID. Details zu Erstellung, Persistenz und Laden beschreibt [[02_Funktionen/Instanzen-erstellen-und-laden|Instanzen erstellen und laden]].

Der Type Body bleibt kompakt und dient als klar sichtbare Verbindungsschicht. Umfangreiche Fachlogik, SQL und Prüfungen liegen in den Packages des Projekts.

## 1. Konkreten Subtyp definieren

Der Typ `FSM_REQ_TYPE` aus der Beispielanwendung erbt von `FSM_TYPE`. Er enthält Konstruktoren, überschreibt `RAISE_EVENT` sowie die benötigten Lifecycle-Hooks und verwendet das geerbte `SET_STATUS`.

```sql
create or replace type fsm_req_type under fsm_type(
  req_id number,
  req_rtp_id varchar2(50 char),
  req_rre_id varchar2(50 char),
  req_text varchar2(1000 char),
  constructor function fsm_req_type(
    self in out nocopy fsm_req_type,
    p_req_id in number default null,
    p_req_rtp_id in varchar2,
    p_req_rre_id in varchar2,
    p_req_text in varchar2)
    return self as result,
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

`REQ_ID` ist die fachliche ID der Anfrage. Die geerbte `FSM_ID` identifiziert parallel den Datensatz in `FSM_OBJECTS`. `REQ_RTP_ID`, `REQ_RRE_ID` und `REQ_TEXT` zeigen, dass der konkrete Typ genau die für seine Fachlogik benötigten Werte ergänzt. Hier müssen nicht notwendigerweise zusätzliche Attribute definiert werden, eine ID auf das Fachobjekt reicht als Minimum aus.

## 2. Type Body dünn halten

Methoden delegieren über direkte PL/SQL-Aufrufe an ein konkretes Package. Oracle prüft Package, Methodennamen, Parameter und Datentypen beim Kompilieren. Umfangreiche Hilfslogik und SQL bleiben dadurch in Packages test- und wartbar.

```sql
overriding member procedure persist_state(
  self in out nocopy fsm_req_type)
as
begin
  fsm_req.set_status(self);
end persist_state;
```

Der Laufzeitkern erreicht diese Implementierung über `p_fsm.persist_state`. Die überschriebene Methode stellt die statische Verbindung zu `FSM_REQ` her. `FSM_REQ.SET_STATUS` persistiert anschließend über `BL_REQUEST` die Zuordnung von `REQ_ID` und `FSM_ID` sowie die konkreten Anfragedaten.

## 3. Konstruktoren implementieren

Der Neu-Zweig setzt alle Attribute vor `SET_STATUS`. Der Lade-Zweig bildet den vorhandenen persistenten Zustand im Objekttyp ab. Siehe [[02_Funktionen/Instanzen-erstellen-und-laden|Instanzen erstellen und laden]].

## 4. Ereignisse behandeln

Das konkrete Package prüft das Ereignis, ruft `FSM.RAISE_EVENT` für den gemeinsamen Ereigniskontext auf, führt die Fachlogik aus und setzt den Zielstatus.

## 5. Hooks überschreiben

- Voraktionen: `BEFORE_TRANSITION`
- konkrete Persistenz: `PERSIST_STATE`
- Aktionen beim Eintritt: `ENTER_STATUS`
- allgemeine Nachaktionen: `AFTER_TRANSITION`
- Aufräumen beim Verlassen: `LEAVE_STATUS`

Hooks ergänzen fachliches Verhalten innerhalb der zentralen Ablauf- und Transaktionskontrolle.

## 6. Metadaten und Konstanten installieren

Klasse, Status, Ereignisse und Transitionen werden über `FSM_ADMIN` registriert. Danach werden `FSM_FST` und `FSM_FEV` erzeugt. Details stehen unter [[03_FSM-verwenden/Metadaten-definieren|Metadaten definieren]].

## Referenz

Die vollständige Implementierung liegt unter:

- `FSM/sample_app/types/fsm_req_type.tps`
- `FSM/sample_app/types/fsm_req_type.tpb`
- `FSM/sample_app/packages/fsm_req.pks`
- `FSM/sample_app/packages/fsm_req.pkb`
- `FSM/sample_app/packages/bl_request.pks`
- `FSM/sample_app/packages/bl_request.pkb`
