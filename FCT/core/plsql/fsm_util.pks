create or replace package FCT_util
  authid current_user
as
  /* Methoden zum gleichzeitigen ersetzen mehrerer Ersetzungfolgen.
   * %param p_value Zeichenkette, in der Ersetzungen vorgenommen werden sollen
   * %param p_replacement Liste von Zeichenfolgen, die als Paar interpretiert
   *        werden.
   * %usage Die Methoden ersetzen in p_value alle Zeichenketten, die sich auf einer
   *        ungeraden Position in der char(clob)_table befinden mit der folgenden
   *        Zeichenkette, aehnlich einer decode()-Anweisung.
   *        Ueberladungen als Prozedur und Funktion sowie fuer varchar2 und clob
   */
  procedure bulk_replace(
    p_value in out nocopy varchar2,
    p_replacement char_table);

  function bulk_replace(
    p_value in varchar2,
    p_replacement char_table) return varchar2;

end FCT_util;
/