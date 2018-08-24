create or replace package util_&TOOLKIT.
  authid current_user
as

  subtype ora_name_type is &ORA_NAME_TYPE.;
  subtype flag_type is char(1 byte);
  subtype max_char is varchar2(32767 byte);
  subtype max_sql_char is varchar2(4000 byte);
  
  /* Packagekonstanten zur Verwendung in abgeleiteten &TOOLKIT.-Instanzen */
  C_OK constant binary_integer := 0;
  C_ERROR constant binary_integer := 1;
  C_TRUE constant flag_type := 'Y';
  C_FALSE constant flag_type := 'N';
  C_CR constant varchar2(2 byte) := chr(10);
  
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

end util_&TOOLKIT.;
/