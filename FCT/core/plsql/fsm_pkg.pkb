create or replace package body &TOOLKIT._pkg
AS
  c_pkg constant varchar2(30 byte) := $$PLSQL_UNIT;
  c_cr constant char(1 byte) := chr(13);

  g_log_level number;
  g_user varchar2(30 byte);

  /* PL/SQL-Tabelle zur Speicherung der Status/Event-spezifischen Benachrichtigungsmails */
  type FCT_message_tab is table of varchar2(200 char)
    index by FCT_status.fst_id%type;

  -- Instanzen
  event_messages FCT_message_tab;
  event_names FCT_message_tab;
  status_messages FCT_message_tab;
  status_names FCT_message_tab;

  /* Initialisierungsprozedur des Packages */
  procedure initialize
  as
    cursor status_message_cur is
      select fst_id, fst_msg_id, fst_name
        from FCT_status;
    cursor event_message_cur is
      select fev_id, fev_msg_id, fev_name
        from FCT_event;
  begin
    --pit.enter_detailed('initialize', c_pkg);
    for fst in status_message_cur loop
      status_messages(fst.fst_id) := fst.fst_msg_id;
      status_names(fst.fst_id) := fst.fst_name;
    end loop;
    for fev in event_message_cur loop
      event_messages(fev.fev_id) := fev.fev_msg_id;
      event_names(fev.fev_id) := fev.fev_name;
    end loop;
    --g_log_level := param.get_integer('PIT_FCT_DEFAULT_LOG_LEVEL', 'PIT');
    g_user := user;
    --pit.leave_detailed;
  end initialize;

  /* HELPER */
  /* Prozedur speichert einen erneuten Ausfuehrungsversuch einer FCT
   * %param p_FCT FCT-Instanz
   * %param p_retry_schedule Schedule, der fuer den erneuten Versuch verwendet
   *        werden soll
   * %usage Wird aufgerufen, wenn ein erneuter Ausfuehrungsversuch einer FCT-Instanz
   *        angeforert wird, um den Versuch zu persistieren
   */
  procedure persist_retry(
    p_FCT in out nocopy FCT_type,
    p_retry_schedule in FCT_object.FCT_retry_schedule%type)
  as
  begin
    --pit.enter_detailed('persist_retry', c_pkg);
    update FCT_object
       set FCT_validity = p_FCT.FCT_validity,
           FCT_retry_schedule = p_retry_schedule
     where FCT_id = p_FCT.FCT_id;
    commit;
    --pit.leave_detailed;
  end persist_retry;


  /* Funktion liefert die aktuelle SESSION_ID, falls ueber APEX keine
   * APEX-Session vereinbart wurde
   */
  function get_session_id
    return varchar2
  as
    l_session_id varchar2(30);
  begin
    --pit.enter_detailed('get_session_id', c_pkg);
    select to_char(sid || ',' || serial#)
      into l_session_id
      from v$session
     where rownum = 1;
    --pit.leave_detailed;
    return l_session_id;
  end get_session_id;


  /* Prozedur fordert einen erneuten Ausfuehrungsversuch an
   * %param p_FCT FCT-Instanz
   * %param p_fev_id Ereignis, das erneut ausgeloest werden soll
   * %param p_wait_time Wartezeit, nach der erneut ausgeloest werden soll
   * %param p_try_count Zaehler, der die Anzahl der Versuche aufzeichnet
   * %usage Wird aufgerufen, um ein Ereignis erneut auszuloesen.
   */
  procedure re_fire_event(
    p_FCT in out nocopy FCT_type,
    p_fev_id in FCT_event.fev_id%type,
    p_wait_time in FCT_status.fst_retry_time%type,
    p_try_count in FCT_status.fst_retries_on_error%type)
  as
    l_result number;
    l_try_count number;
  begin
    --pit.enter_optional('re_fire_event', c_pkg);
    if p_wait_time is not null then
      /*pit.info(
        msg.FCT_RETRYING,
        msg_args(
          p_fev_id,
          p_FCT.FCT_fst_id,
          p_FCT.FCT_fev_list,
          to_char(p_try_count)),
          p_FCT.FCT_id);*/
      -- Wait and retry status change
      dbms_lock.sleep(p_wait_time);
      l_result := p_FCT.raise_event(p_fev_id);
    end if;
    --pit.leave_optional;
  end re_fire_event;


  /* Prozedur stoppt die erneute Ausloesung eines Ereignisses und setzt die Instanz
   * in den Fehlestatus
   * %param p_FCT FCT-Instanz
   * %usage Sind keine erneuten Ausloesungen des Ereignisses erlaubt oder die maximale
   *        Wiederholungszahl erreicht, wird ein Fehlerereignis ausgeloest und die
   *        Verarbeitung gestoppt
   */
  procedure proceed_with_error_event(
    p_FCT in out nocopy FCT_type)
  as
    l_result number;
    l_event FCT_event.fev_id%type;
  begin
    --pit.enter_optional('proceed_with_error_event', c_pkg);
    /*pit.verbose(
      msg.FCT_VALIDITY,
      msg_args(
        to_char(p_FCT.FCT_validity)),
        p_FCT.FCT_id);*/
    select ftr_fev_id
      into l_event
      from FCT_transition
     where ftr_fst_id = p_FCT.FCT_fst_id
       and ftr_fcl_id = p_FCT.FCT_fcl_id
       and ftr_raise_on_status = c_error;
--    pit.verbose(msg.FCT_THROW_ERROR_EVENT, msg_args(l_event), p_FCT.FCT_id);

    p_FCT.FCT_fev_list := l_event;
    p_FCT.FCT_validity := c_error;

    persist_retry(p_FCT, null);

    l_result := p_FCT.raise_event(l_event);
    --pit.leave_optional;
  exception
    when no_data_found then
      -- Werfe generischen Fehler
      l_result := p_FCT.raise_event(FCT_fev.FCT_ERROR);
  end proceed_with_error_event;


  /* Prozdur zur Pflege von FCT_LOG
   * %param p_FCT FCT-Instanz
   * %param p_fev_id Ereignis, das ausgeloest wurde (optional)
   * %param p_fst_id Neuer Status, der eingenommen wurde (optional)
   * %param p_msg ID einer Nachricht aus PIT
   * %param p_msg_args MSG_ARGS-Instanz mit Nachrichtenparametern
   * %usage Wird aufgerufen, um Statuswechsel, Ereignisse und Notifications von
   *        FCT zu protokollieren
   */
  procedure log_change(
    p_FCT in out nocopy FCT_type,
    p_fev_id in FCT_event.fev_id%type default null,
    p_fst_id in FCT_status.fst_id%type default null,
    p_msg in varchar2 default null/*,
    p_msg_args in msg_args default null*/)
  as
  --  l_message message_type;
   -- l_message_id message.message_name%type;
    l_user varchar2(50);
    l_session varchar2(50);
    --l_msg_args msg_args;
    c_pit_FCT constant varchar2(10) := 'PIT_FCT';
  begin
    --pit.enter_optional('log_change', c_pkg);
    -- prepare Message
    /*case
    when p_fev_id is not null then
      --l_message_id := event_messages(p_fev_id);
      --l_msg_args := msg_args(event_names(p_fev_id));
    when p_fst_id = FCT_fst.FCT_ERROR then
      --l_message_id := msg.FCT_DELIVERY_FAILED;
      --l_msg_args := msg_args(status_names(p_fst_id));
    when p_fst_id is not null then
      --l_message_id := status_messages(p_fst_id);
      --l_msg_args := msg_args(status_names(p_fst_id));
    else
      --l_message_id := p_msg;
      --l_msg_args := p_msg_args;
    end case;
*/
    --l_message := pit_pkg.get_message(l_message_id, to_char(p_FCT.FCT_id), l_msg_args);
    -- TODO: Pruefen, ob Ermittlung des Username/Session durch APEX_ADAPTER buggy ist
  --  if instr(l_message.session_id, ':') > 0 then
    --  l_user := substr(l_message.session_id, 1, instr(l_message.session_id, ':') - 1);
    --  l_session := substr(l_message.session_id, instr(l_message.session_id, ':') + 1);
   -- else
      l_user := g_user;
      l_session := get_session_id;
   -- end if;

    -- LOG
    insert into FCT_log(
      fsl_id, /*fsl_FCT_id,*/ fsl_session_id, fsl_user_name,
      fsl_log_date, --fsl_msg_text, fsl_severity,
      fsl_fst_id, fsl_fev_list, fsl_fcl_id/*,
      fsl_msg_id, fsl_msg_args*/)
    values(
      FCT_log_seq.nextval, /*to_number(l_message.affected_id),*/ l_session, l_user,
      current_timestamp, --l_message.message_text, l_message.severity,
      p_FCT.FCT_fst_id, p_FCT.FCT_fev_list, p_FCT.FCT_fcl_id/*,
      l_message.message_name, pit_pkg.cast_to_char_list(l_message.message_args)*/
      );
    --pit.leave_optional;
  end log_change;


  /* INTERFACE */
  procedure persist(
    p_FCT in FCT_type)
  as
  begin
--    pit.enter('persist', c_pkg, msg_params(msg_param('id', p_FCT.FCT_id)));
    merge into FCT_object o
    using (select p_FCT.FCT_id FCT_id,
                  p_FCT.FCT_fcl_id FCT_fcl_id,
                  p_FCT.FCT_fst_id FCT_fst_id,
                  coalesce(p_FCT.FCT_validity, c_ok) FCT_validity,
                  p_FCT.FCT_fev_list FCT_fev_list
             from dual) v
       on (o.FCT_id = v.FCT_id)
     when matched then update set
          FCT_fst_id = v.FCT_fst_id,
          FCT_validity = v.FCT_validity,
          FCT_fev_list = v.FCT_fev_list
     when not matched then insert(FCT_id, FCT_fcl_id, FCT_fst_id, FCT_validity, FCT_fev_list)
          values(v.FCT_id, v.FCT_fcl_id, v.FCT_fst_id, v.FCT_validity, v.FCT_fev_list);
    --pit.leave;
  end persist;


  function raise_event(
    p_FCT in out nocopy FCT_type,
    p_fev_id in FCT_event.fev_id%type)
    return integer
  as
   -- l_message_id message.message_name%type;
    l_old_fst_id FCT_status.fst_id%type;
    l_new_fst_id FCT_status.fst_id%type;
  begin
    --pit.enter('raise_event', c_pkg);
    -- LOG verwalten
    log_change(
      p_FCT => p_FCT,
      p_fev_id => p_fev_id);
    p_FCT.FCT_validity := c_ok;
    --pit.leave;
    return c_ok;
  exception
    when others then
      --pit.sql_exception(msg.FCT_SQL_ERROR, msg_args(p_FCT.FCT_fcl_id, to_char(p_FCT.FCT_id), p_fev_id));
      return c_error;
  end raise_event;


  procedure retry(
    p_FCT in out nocopy FCT_type,
    p_fev_id in FCT_event.fev_id%type)
  as
    cursor FCT_cur (p_FCT_id in FCT_object.FCT_id%type) is
      select FCT.FCT_validity,
             FCT.FCT_fev_id,
             fst.fst_id,
             fst.fst_retries_on_error,
             fst.fst_retry_schedule,
             fst.fst_retry_time
        from FCT_object FCT
        join FCT_status fst
          on FCT.FCT_fst_id = fst.fst_id
         and FCT.FCT_fcl_id = fst.fst_fcl_id
       where FCT.FCT_id = p_FCT.FCT_id
         and FCT.FCT_validity != 1;
    l_validity FCT_object.FCT_validity%type;
  begin
    --pit.enter('retry', c_pkg);
    for FCT in FCT_cur(p_FCT.FCT_id) loop
      if FCT.fst_retries_on_error > 0 then
        --pit.verbose(msg.FCT_RETRY_REQUESTED, msg_args(p_fev_id, FCT.fst_id, c_true), p_FCT.FCT_id);
        -- take retry into account
        -- FCT_VALIDITY may have one of the following values:
        -- 0 = no retry planned yet (or succesful state conversion, then this method wouldn't have been called)
        -- 1 = Error, proceed with ftr_raise_on_status = 1 event
        -- > 1 = Retry already scheduled, register next try.
        case FCT.FCT_validity
        when 0 then
          -- retry not yet scheduled
          p_FCT.FCT_validity := FCT.fst_retries_on_error + 1;
          persist_retry(p_FCT, FCT.fst_retry_schedule);
          re_fire_event(p_FCT, p_fev_id, FCT.fst_retry_time, 1);
        when 1 then
          -- STUB, can not possibly happen
          proceed_with_error_event(p_FCT);
        when 2 then
          proceed_with_error_event(p_FCT);
        else
          p_FCT.FCT_validity := FCT.FCT_validity - 1;
          /*if p_FCT.FCT_validity > 2 then
            p_FCT.notify(msg.FCT_RETRY_INFO);
          else
            p_FCT.notify(msg.FCT_RETRY_WARN);
          end if;*/
          persist_retry(p_FCT, FCT.fst_retry_schedule);
          l_validity := FCT.fst_retries_on_error - FCT.FCT_validity + 1;
          re_fire_event(p_FCT, p_fev_id, FCT.fst_retry_time, l_validity);
        end case;
      else
        --pit.verbose(msg.FCT_RETRY_REQUESTED, msg_args(p_fev_id, FCT.fst_id, c_false), p_FCT.FCT_id);
        proceed_with_error_event(p_FCT);
      end if;
      --pit.leave;
    end loop;
  end retry;


  function allows_event(
    p_FCT in out nocopy FCT_type,
    p_fev_id FCT_event.fev_id%type)
    return boolean
  as
    l_result boolean;
    l_has_role number;
  begin
    --pit.enter_optional('FCT_allows_event', c_pkg);
    -- Pruefe, ob Event im aktuellen Status erlaubt ist
    l_result := instr(':' || p_FCT.FCT_fev_list || ':', ':' || p_fev_id || ':') > 0;

    -- Pruefe, ob aktueller Benutzer erforderliche Rollenrechte besitzt
    select case
           when ftr_required_role is not null then 0 --auth_user.is_authorized(ftr_required_role)
           else 1 end
      into l_has_role
      from FCT_transition
     where ftr_fev_id = p_fev_id
       and ftr_fst_id = p_FCT.FCT_fst_id
       and ftr_fcl_id = p_FCT.FCT_fcl_id;

    --pit.leave_optional;
    return l_result and l_has_role > 0;
  exception
    when no_data_found then
      return false;
  end allows_event;


  function set_status(
    p_FCT in out nocopy FCT_type)
    return number
  as
    cursor next_event_cur(p_FCT in FCT_type) is
      select listagg(fev_id, ':') within group (order by fev_id) fev_list,
             max(ftr_raise_automatically) event_auto
        from bl_FCT_active_status_event
       where fst_id = p_FCT.FCT_fst_id
         and fcl_id = p_FCT.FCT_fcl_id
         and ftr_raise_on_status = p_FCT.FCT_validity;
    l_old_fst_id FCT_status.fst_id%type;
    l_result number := c_ok;
  begin
    --pit.enter('set_status', c_pkg);
    --pit.assert_not_null(p_FCT.FCT_fst_id);
    p_FCT.FCT_validity := coalesce(p_FCT.FCT_validity, c_ok);

    -- Ermittle nÃ¤chste mÃ¶gliche Events
    for evt in next_event_cur(p_FCT) loop
      p_FCT.FCT_fev_list := evt.fev_list;
      p_FCT.FCT_auto_raise := evt.event_auto;
    end loop;

    persist(p_FCT);

    log_change(
      p_FCT => p_FCT,
      p_fst_id => p_FCT.FCT_fst_id);

    --notify(p_FCT, msg.FCT_NEXT_EVENTS, msg_args(p_FCT.FCT_fev_list, p_FCT.FCT_auto_raise));

    --pit.leave;
    return p_FCT.FCT_validity;
  exception
    /*when msg.ASSERTION_FAILED_ERR then
      if p_FCT.FCT_fst_id != FCT_fst.FCT_ERROR then
        p_FCT.FCT_fst_id := FCT_fst.FCT_ERROR;
        return set_status(p_FCT);
      else
        return c_error;
      end if;*/
    when others then
--      pit.sql_exception(msg.SQL_ERROR);
      if p_FCT.FCT_fst_id != FCT_fst.FCT_ERROR then
        p_FCT.FCT_fst_id := FCT_fst.FCT_ERROR;
        return set_status(p_FCT);
      else
        return c_error;
      end if;
  end set_status;


  procedure set_status(
    p_FCT in out nocopy FCT_type)
  as
    l_result number;
  begin
    l_result := set_status(p_FCT);
  end set_status;


  function get_next_status(
    p_FCT in out nocopy FCT_type,
    p_fev_id in FCT_event.fev_id%type)
    return varchar2
  as
    l_next_fst_id varchar2(4000);
    c_delimiter constant varchar2(1) := ':';
  begin
    select listagg(ftr_fst_list, c_delimiter) within group (order by ftr_fst_list)
      into l_next_fst_id
      from FCT_transition
     where ftr_fst_id = p_FCT.FCT_fst_id
       and ftr_fev_id = p_fev_id
       and ftr_fcl_id = p_FCT.FCT_fcl_id;
    if instr(l_next_fst_id, c_delimiter) = 0 then
--      notify(p_FCT, msg.FCT_NEXT_STATUS_RECOGNIZED, msg_args(l_next_fst_id));
      return l_next_fst_id;
    else
--      pit.error(msg.FCT_NEXT_STATUS_NU, msg_args(p_FCT.FCT_fst_id), p_FCT.FCT_id);
      return null;
    end if;
  exception
    when no_data_found then
--      pit.error(msg.FCT_NEXT_STATUS_NU, msg_args(p_FCT.FCT_fst_id), p_FCT.FCT_id);
      return null;
  end get_next_status;


  procedure notify(
    p_FCT in out nocopy FCT_type,
    p_msg in varchar2/*,
    p_msg_args in msg_args*/)
  as
  begin
    --pit.enter('notify', c_pkg);
    log_change(
      p_FCT => p_FCT,
      p_msg => p_msg/*,
      p_msg_args => p_msg_args*/
      );
    --pit.leave;
  end notify;


  function to_string(
    p_FCT in FCT_type)
    return varchar2
  as
    l_result varchar2(32767) :=
    q'[Instanz vom Typ FCT_TYPE
    FCT_ID: #FCT_ID#
    FCT_fcl_id: #FCT_FCL_ID#
    FCT_fst_id: #FCT_FST_ID#
    FCT_VALIDITY: #FCT_VALIDITY#
    event_list: #FEV_LIST#
]';
  begin
    FCT_util.bulk_replace(l_result, char_table(
      '#FCT_ID#', p_FCT.FCT_id,
      '#FCT_FCL_ID#', p_FCT.FCT_fcl_id,
      '#FCT_FST_ID#', p_FCT.FCT_fst_id,
      '#FCT_VALIDITY#', p_FCT.FCT_validity,
      '#FEV_LIST#', p_FCT.FCT_fev_list));
    return l_result;
  end to_string;


  procedure finalize(
    p_FCT FCT_type)
  as
  begin
    null;
  end finalize;

begin
  initialize;
end &TOOLKIT._pkg;
/
