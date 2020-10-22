create or replace package &TOOLKIT._pkg
  authid definer
as
  /* Package zur generischen Verwaltung einer Finite State Machine (&TOOLKIT.)
   * %usage: Das Package beinhaltet die Implementierung der abstrakten Klasse
   *         &TOOLKIT._TYPE und stellt generische Funktionen zum Logging, zur Verwaltung
   *         von Events und Statusänderungen bereit.
   */


  /* Funktion hat auf abstrakter Ebene lediglich die Aufgabe, das Logging
   * zu uebernehmen.
   * %param p_&TOOLKIT. Instanz der Klasse &TOOLKIT._TYPE
   * %param p_fev_id Event, der ausgeloest wurde
   * %return C_OK oder C_ERROR. C_ERROR nur dann, wenn kein Logging durchgefuehrt
   *         werden konnte.
   * %usage wird von der entpsrechenden Funktion des Typs &TOOLKIT._TYPE aufgerufen.
   */
  function raise_event(
    p_&TOOLKIT. in out nocopy &TOOLKIT._type,
    p_fev_id in &TOOLKIT._event.fev_id%type)
    return integer;


  /* "Konstruktor"-Prozedur: Erstellt kein Objekt, sondern lediglich Einträge
   * in &TOOLKIT._OBJECT als Referenzpunkt für Konstruktormethoden der abgeleiteten Klassen.
   * %param p_&TOOLKIT. &TOOLKIT._TYPE-Instanz
   * %usage Wird von den Konstruktoren der abgeleiteten Klassen aufgerufen, um
   *        einen Eintrag in &TOOLKIT._OBJECT zu erstellen. Falls vorhanden, werden Attribute
   *        aktualisiert, ansonsten wird die Klasse neu angelegt.
   */
  procedure persist(
    p_&TOOLKIT. in &TOOLKIT._type);


  /* Prozedur, die aufgerufen wird, wenn ein Event einen Fehler produziert.
   * Die Methode prueft, ob das Event noch einmal ausgefuehrt werden kann
   * (basierend evtl. auf einem Schedule) und wirft den Event erneut.
   * Falls nicht, wird die &TOOLKIT. auf Status ERROR gesetzt.
   * %param p_&TOOLKIT. &TOOLKIT._TYPE-Instanz
   * %param p_fev_id Ereignis, dass einen Fehler erhalten hat.
   * %usage Wird aufgerufen, wenn ein Event-Handler einen Fehler wirft.
   */
  procedure retry(
    p_&TOOLKIT. in out nocopy &TOOLKIT._type,
    p_fev_id in &TOOLKIT._event.fev_id%type);


  /* Funktion prueft, ob eine &TOOLKIT. einen gesuchten Event erlaubt.
   * %param p_&TOOLKIT. &TOOLKIT.-Instanz
   * %param p_fev_id Event, der geprueft wird
   * %return Flag, das anzeigt, ob der gesuchte Event erlaubt ist (true) oder nicht (false)
   * %usage Wird von der APEX-Anwendung aufgerufen, um zu pruefen, ob ein Control
   *        angezeigt oder ausgefuehrt werden soll
   */
  function allows_event(
    p_&TOOLKIT. in out nocopy &TOOLKIT._type,
    p_fev_id &TOOLKIT._event.fev_id%type)
    return boolean;


  /* Funktion zum Ändern eines Status.
   * %param p_&TOOLKIT. Instanz der &TOOLKIT. (konkrete Klasse des von &TOOLKIT._TYPE geerbeten Typs)
   * %return Erfolgflag. Normalerweise 0 = Fehler oder 1 = OK. Es können aber auch
   *         weitere Returnwerte verarbeitet werden. Die Werte werden in &TOOLKIT._VALIDITY
   *         des &TOOLKIT.-Objekts gespeichert.
   * %usage Ein neuer Status wird durch die Logik des Eventhandlers bestimmt und
   *        in die Klasse eingetragen. Auf Basis des neuen Status können weitere
   *        Events ermittelt werden, die nun ausgelöst werden können.
   *        Ist der nachfolgende Event automatisch, wird er unmittelbar ausgelöst,
   *        ansonsten wartet die &TOOLKIT. auf die Auslösung des entsprechenden Status.
   */
  function set_status(
    p_&TOOLKIT. in out nocopy &TOOLKIT._type)
    return number;

  procedure set_status(
    p_&TOOLKIT. in out nocopy &TOOLKIT._type);


  /* Funktion zur Ermittlung des naechsten, moeglichen Status
   * %param p_&TOOLKIT. Instanz vom Typ &TOOLKIT._TYPE
   * %return Name des naechsten Status
   * %usage Die Funktion wird gerufen, um den naechsten Status aus einer Liste
   *        von Werten zu ermitteln. Ist kein naechster Status vorhanden,
   *        wird ein Fehler geworfen, da dies durch eine falsche Paramtrierung
   *        verursacht wird.
   *        Ein Aufruf ist nur moeglich, wenn von einem Status lediglich zu einem
   *        weiteren Status gewechselt werden kann. Koennen mehrere Status
   *        erreicht werden, muss der Status durch Logik ermittelt und direkt
   *        gesetzt werden.
   */
  function get_next_status(
    p_&TOOLKIT. in out nocopy &TOOLKIT._type,
    p_fev_id in &TOOLKIT._event.fev_id%type)
    return varchar2;


  /* Prozedur speichert eine Notiz zu einer &TOOLKIT.-Instanz
   * %param p_&TOOLKIT. Instanz von &TOOLKIT._TYPE, zu der eine Notiz gespeichert werden soll
   * %param p_note_type Referenz auf MSG, wird als Meldung erstellt
   * %param p_comment zusätzlicher Kommentar, Freitext, wird als MSG_ARG interpretiert
   * %usage Die Prozedur wird während der Bearbeitung aufgerufen, um Vermerke
   *        zur Bearbeitung zu speichern
   */
  procedure notify(
    p_&TOOLKIT. in out nocopy &TOOLKIT._type,
    p_msg in util_&TOOLKIT..ora_name_type,
    p_msg_args in msg_args);


  /* Funktion zur Umwandlung des Objects in eine Zeichenkette
   * %param p_&TOOLKIT. Instanz, die umgewandelt werden soll
   * %return Zeichenkette mit den relevanten Klassenattributen
   * %usage wird verwendet, um eine Uebersicht ueber die Klassenattribte zu erhalten.
   */
  function to_string(
    p_&TOOLKIT. in &TOOLKIT._type)
    return varchar2;


  /* "Destruktor", bereinigt das Objekt
   */
  procedure finalize(
    p_&TOOLKIT. in &TOOLKIT._type);

end &TOOLKIT._pkg;
/