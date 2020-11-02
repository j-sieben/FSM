create or replace package body fsm 
as
  
  g_log_level number;
  g_user ora_name_type;
  
  /* PL/SQL table to cache notification messages */
  type fsm_message_tab is table of varchar2(200 char) index by fsm_status.fst_id%type;
  
  -- Instances
  g_event_messages fsm_message_tab;
  g_event_names fsm_message_tab;
  g_status_messages fsm_message_tab;
  g_status_names fsm_message_tab;
  
  /* Initialize package */
  procedure initialize
  as
    cursor status_message_cur is
      select fst_id, fst_msg_id, fst_name
        from fsm_status_v;
    cursor event_message_cur is
      select fev_id, fev_msg_id, fev_name
        from fsm_events_v;
  begin
    pit.enter_detailed;
    
    -- cache list of often used messages for status
    for fst in status_message_cur loop
      g_status_messages(fst.fst_id) := fst.fst_msg_id;
      g_status_names(fst.fst_id) := fst.fst_name;
    end loop;
    -- ... and events
    for fev in event_message_cur loop
      g_event_messages(fev.fev_id) := fev.fev_msg_id;
      g_event_names(fev.fev_id) := fev.fev_name;
    end loop;
    
    g_log_level := param.get_integer('PIT_fsm_DEFAULT_LOG_LEVEL', 'PIT');
    g_user := user;
    
    pit.leave_detailed;
  end initialize;
  
  /* HELPER */
  /* Methode persists retry of a FSM instance to achieve a new status 
   * @param  p_fsm             FSM instance
   * @param  p_retry_schedule  Schedule to be used for the next retry
   * @usage  Is called when a FSM instance could not achieve a new status and retries to reach it.
   *         This method persists the retry event
   */
  procedure persist_retry(
    p_fsm in out nocopy fsm_type,
    p_retry_schedule in fsm_objects.fsm_retry_schedule%type)
  as
  begin
    pit.enter_detailed(
      p_params => msg_params(
                    msg_param('p_fsm', 'opaque'),
                    msg_param('p_retry_schedule', p_retry_schedule)));
    
    update fsm_objects
       set fsm_validity = p_fsm.fsm_validity,
           fsm_retry_schedule = p_retry_schedule
     where fsm_id = p_fsm.fsm_id;
    commit;
    
    pit.leave_detailed;
  end persist_retry;
  
  
  /* Methode delivers the actual session id as offerd in V$SESSION
   * @return Session-ID string (SID,SERIAL#)
   */
  function get_session_id
    return varchar2
  as
    l_session_id ora_name_type;
  begin
    pit.enter_detailed;
    
    select to_char(sid || ',' || serial#)
      into l_session_id
      from v$session
     where rownum = 1;
     
    pit.leave_detailed(
      p_params => msg_params(
                    msg_param('Session-ID', l_session_id)));
    return l_session_id;
  end get_session_id;
  
  
  /* Method tries to re-fire an event that has not succeeded before
   * @param  p_fsm        FSM instance
   * @param  p_fev_id     Event to raise
   * @param  p_wait_time  wait time after which the event is raised
   * @param  p_try_count  Counter that counts the amount of tries
   * @usage  Is called to re-raise an event.
   */
  procedure re_fire_event(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events.fev_id%type,
    p_wait_time in fsm_status.fst_retry_time%type,
    p_try_count in fsm_status.fst_retries_on_error%type)
  as
    l_result binary_integer;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_fsm', 'opaque'),
                    msg_param('p_fev_id', p_fev_id),
                    msg_param('p_wait_time', p_wait_time),
                    msg_param('p_try_count', p_try_count)));
                    
    if p_wait_time is not null then
      pit.info(
        msg.fsm_RETRYING, 
        msg_args(
          p_fev_id, 
          p_fsm.fsm_fst_id, 
          p_fsm.fsm_fev_list, 
          to_char(p_try_count)), 
          p_fsm.fsm_id);
      -- Wait and retry status change
      dbms_lock.sleep(p_wait_time);
      l_result := p_fsm.raise_event(p_fev_id);
    end if;
    
    pit.leave_optional;
  end re_fire_event;
  
  
  /* Procedure stops retriggering an event and sets the instance to error status
   * @param  p_fsm  FSM instance
   * @usage  As no retry is allowed, the method examines the metadata to find
   *         transitions that have to be executed in case of error. If no transition
   *         is found, it will use a generic FSM_ERROR event.
   */
  procedure proceed_with_error_event(
    p_fsm in out nocopy fsm_type)
  as
    l_result binary_integer;
    l_event fsm_events.fev_id%type;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_fsm', 'opaque')));
    pit.verbose(
      msg.fsm_VALIDITY, 
      msg_args(
        to_char(p_fsm.fsm_validity)),
        p_fsm.fsm_id);
    select ftr_fev_id
      into l_event
      from fsm_transitions
     where ftr_fst_id = p_fsm.fsm_fst_id
       and ftr_fcl_id = p_fsm.fsm_fcl_id
       and ftr_raise_on_status = C_ERROR;
    pit.verbose(msg.fsm_THROW_ERROR_EVENT, msg_args(l_event), p_fsm.fsm_id);
    
    p_fsm.fsm_fev_list := l_event;
    p_fsm.fsm_validity := C_ERROR;
    
    persist_retry(p_fsm, null);
    
    l_result := p_fsm.raise_event(l_event);
    pit.leave_optional;
  exception
    when no_data_found then
      -- Throw generic error
      l_result := p_fsm.raise_event(fsm_fev.FSM_ERROR);
  end proceed_with_error_event;
  
  
  /* Procedure to maintain FSM_LOG
   * @param  p_fsm       FSM instance
   * @param [p_fev_id]   Event that was triggered
   * @param [p_fst_id]   New status that was taken
   * @param [p_msg]      ID of a message from PIT
   * @param [p_msg_args] MSG_ARGS instance with message parameters
   * @usage  Called to log status changes, events and notifications from FSM
   */
  procedure log_change(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events.fev_id%type default null,
    p_fst_id in fsm_status.fst_id%type default null,
    p_msg in varchar2 default null,
    p_msg_args in msg_args default null)
  as
    l_message message_type;
    l_message_id fsm_events.fev_msg_id%type;
    l_user ora_name_type;
    l_session ora_name_type;
    l_msg_args msg_args;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_fsm', 'opaque'),
                    msg_param('p_fev_id', p_fev_id),
                    msg_param('p_fst_id', p_fst_id),
                    msg_param('p_msg', p_msg),
                    msg_param('p_msg_args', 'opaque')));
                    
    -- choose appropriate message based on parameters entered
    case
    when p_fev_id is not null then
      l_message_id := g_event_messages(p_fev_id);
      l_msg_args := msg_args(g_event_names(p_fev_id));
    when p_fst_id = fsm_fst.fsm_ERROR then
      l_message_id := msg.fsm_DELIVERY_FAILED;
      l_msg_args := msg_args(g_status_names(p_fst_id));
    when p_fst_id is not null then
      l_message_id := g_status_messages(p_fst_id);
      l_msg_args := msg_args(g_status_names(p_fst_id));
    else
      l_message_id := p_msg;
      l_msg_args := p_msg_args;
    end case;
    
    -- create message
    l_message := pit.get_message(
                   p_message_name => l_message_id,
                   p_msg_args => l_msg_args, 
                   p_affected_id => to_char(p_FSM.FSM_id));
    
    -- Session ID may contain Session ID and user name. Split
    if instr(l_message.session_id, ':') > 0 then
      l_user := substr(l_message.session_id, 1, instr(l_message.session_id, ':') - 1);
      l_session := substr(l_message.session_id, instr(l_message.session_id, ':') + 1);
    else
      l_user := g_user;
      l_session := get_session_id;
    end if;
    
    -- LOG
    insert into fsm_log(
      fsl_id, fsl_fsm_id, fsl_session_id, fsl_user_name, 
      fsl_log_date, fsl_msg_text, fsl_severity, 
      fsl_fst_id, fsl_fev_list, fsl_fcl_id, 
      fsl_msg_id, fsl_msg_args)
    values(
      fsm_log_seq.nextval, to_number(l_message.affected_id), l_session, l_user,
      current_timestamp, l_message.message_text, l_message.severity,
      p_fsm.fsm_fst_id, p_fsm.fsm_fev_list, p_fsm.fsm_fcl_id,
      l_message.message_name, pit_util.cast_to_msg_args_char(l_message.message_args));
      
    pit.leave_optional;
  end log_change;
  
  
  /* INTERFACE */
  procedure persist(
    p_fsm in fsm_type)
  as
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_fsm', 'opaque')));
    merge into fsm_objects o
    using (select p_fsm.fsm_id fsm_id,
                  p_fsm.fsm_fcl_id fsm_fcl_id,
                  p_fsm.fsm_fst_id fsm_fst_id,
                  coalesce(p_fsm.fsm_validity, C_OK) fsm_validity,
                  p_fsm.fsm_fev_list fsm_fev_list
             from dual) v
       on (o.fsm_id = v.fsm_id)
     when matched then update set
          fsm_fst_id = v.fsm_fst_id,
          fsm_validity = v.fsm_validity,
          fsm_fev_list = v.fsm_fev_list
     when not matched then insert(fsm_id, fsm_fcl_id, fsm_fst_id, fsm_validity, fsm_fev_list)
          values(v.fsm_id, v.fsm_fcl_id, v.fsm_fst_id, v.fsm_validity, v.fsm_fev_list);
          
    pit.leave_mandatory;
  end persist;
  

  function raise_event(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events.fev_id%type)
    return integer
  as
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_fsm', 'opaque'),
                    msg_param('p_fev_id', p_fev_id)));
    -- LOG verwalten
    log_change(
      p_fsm => p_fsm, 
      p_fev_id => p_fev_id);
    p_fsm.fsm_validity := C_OK;
    
    pit.leave_mandatory(
      p_params => msg_params(
                    msg_param('Status', C_OK)));
    return C_OK;
  exception
    when others then
      pit.handle_exception(msg.fsm_SQL_ERROR, msg_args(p_fsm.fsm_fcl_id, to_char(p_fsm.fsm_id), p_fev_id));
      return C_ERROR;
  end raise_event;
    
  
  procedure retry(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events.fev_id%type)
  as
    cursor fsm_cur (p_fsm_id in fsm_objects.fsm_id%type) is
      select fsm.fsm_validity,
             fsm.fsm_fev_id,
             fst.fst_id,
             fst.fst_retries_on_error, 
             fst.fst_retry_schedule, 
             fst.fst_retry_time
        from fsm_objects fsm
        join fsm_status fst
          on fsm.fsm_fst_id = fst.fst_id
         and fsm.fsm_fcl_id = fst.fst_fcl_id
       where fsm.fsm_id = p_fsm.fsm_id
         and fsm.fsm_validity != 1;
    l_validity fsm_objects.fsm_validity%type;
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_fsm', 'opaque'),
                    msg_param('p_fev_id', p_fev_id)));
                    
    for fsm in fsm_cur(p_fsm.fsm_id) loop
      if fsm.fst_retries_on_error > C_ERROR then
        pit.verbose(msg.fsm_RETRY_REQUESTED, msg_args(p_fev_id, fsm.fst_id, C_TRUE), p_fsm.fsm_id);
        -- take retry into account
        -- fsm_VALIDITY may have one of the following values:
        -- C_OK = no retry planned yet (or succesful state conversion, then this method wouldn't have been called)
        -- C_ERROR = Error, proceed with FTR_RAISE_ON_STATUS = 1 event
        -- > 1 = Retry already scheduled, register next try.
        case fsm.fsm_validity 
        when C_OK then
          -- retry not yet scheduled
          p_fsm.fsm_validity := fsm.fst_retries_on_error + 1;
          persist_retry(p_fsm, fsm.fst_retry_schedule);
          re_fire_event(p_fsm, p_fev_id, fsm.fst_retry_time, 1);
        when C_ERROR then
          -- STUB, can not possibly happen
          proceed_with_error_event(p_fsm);
        when 2 then
          proceed_with_error_event(p_fsm);
        else
          p_fsm.fsm_validity := fsm.fsm_validity - 1;
          if p_fsm.fsm_validity > 2 then
            p_fsm.notify(msg.fsm_RETRY_INFO);
          else
            p_fsm.notify(msg.fsm_RETRY_WARN);
          end if;
          persist_retry(p_fsm, fsm.fst_retry_schedule);
          l_validity := fsm.fst_retries_on_error - fsm.fsm_validity + 1;
          re_fire_event(p_fsm, p_fev_id, fsm.fst_retry_time, l_validity);
        end case;
      else
        pit.verbose(msg.fsm_RETRY_REQUESTED, msg_args(p_fev_id, fsm.fst_id, C_FALSE), p_fsm.fsm_id);
        proceed_with_error_event(p_fsm);
      end if;
      
    end loop;
    
    pit.leave_mandatory;
  end retry;
  
  
  function allows_event(
    p_fsm in out nocopy fsm_type,
    p_fev_id fsm_events.fev_id%type)
    return boolean
  as
    l_result boolean;
    l_has_role binary_integer;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_fsm', 'opaque'),
                    msg_param('p_fev_id', p_fev_id)));
                    
    -- Check if event is allowed in current state
    l_result := instr(':' || p_fsm.fsm_fev_list || ':ERROR:', ':' || p_fev_id || ':') > C_ERROR;
    
    -- Check if current user has required role rights
    select case 
           when ftr_required_role is not null then C_ERROR -- auth_user.is_authorized(ftr_required_role)
           else C_OK end
      into l_has_role
      from fsm_transitions
     where ftr_fev_id = p_fev_id
       and ftr_fst_id = p_fsm.fsm_fst_id
       and ftr_fcl_id = p_fsm.fsm_fcl_id;
    
    pit.leave_optional;
    return l_result and l_has_role > C_ERROR;
  exception
    when no_data_found then
      pit.leave_optional;
      return false;
  end allows_event;
  
  
  function set_status(
    p_fsm in out nocopy fsm_type)
    return number
  as
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_fsm', 'opaque')));
                    
    pit.assert_not_null(p_fsm.fsm_fst_id);
    p_fsm.fsm_validity := coalesce(p_fsm.fsm_validity, C_OK);
    
    -- Find out the next possible events
    SELECT listagg(fev_id, ':') within GROUP(ORDER BY fev_id) fev_list,
           MAX(ftr_raise_automatically) event_auto
      INTO p_fsm.fsm_fev_list,
           p_fsm.fsm_auto_raise
      FROM bl_fsm_active_status_event
     WHERE fst_id = p_fsm.fsm_fst_id
       AND fcl_id = p_fsm.fsm_fcl_id
       AND ftr_raise_on_status = p_FSM.FSM_validity;
    
    persist(p_fsm);
    
    log_change(
      p_fsm => p_fsm,
      p_fst_id => p_fsm.fsm_fst_id);
    
    notify(p_fsm, msg.fsm_NEXT_EVENTS, msg_args(p_fsm.fsm_fev_list, p_fsm.fsm_auto_raise));
    
    pit.leave_mandatory(
      p_params => msg_params(
                    msg_param('Result', p_fsm.fsm_validity)));
    return p_fsm.fsm_validity;
  exception
    when msg.ASSERTION_FAILED_ERR then
      if p_fsm.fsm_fst_id != fsm_fst.fsm_ERROR then
        p_fsm.fsm_fst_id := fsm_fst.fsm_ERROR;
        
        pit.leave_mandatory;
        return set_status(p_fsm);
      else
        pit.leave_mandatory;
        return C_ERROR;
      end if;
    when others then
      pit.handle_exception(msg.SQL_ERROR);
      if p_fsm.fsm_fst_id != fsm_fst.fsm_ERROR then
        p_fsm.fsm_fst_id := fsm_fst.fsm_ERROR;
        return set_status(p_fsm);
      else
        pit.leave_mandatory;
        return C_ERROR;
      end if;
  end set_status;
  
  
  procedure set_status(
    p_fsm in out nocopy fsm_type)
  as
    l_result number;
  begin
    l_result := set_status(p_fsm);
  end set_status;
  
  
  function get_next_status(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events.fev_id%type)
    return varchar2
  as
    l_next_fst_list max_sql_char;
    C_DELIMITER constant varchar2(1) := ':';
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_fev_id', p_fev_id)));
                    
    select listagg(ftr_fst_list, C_DELIMITER) within group (order by ftr_fst_list)
      into l_next_fst_list
      from fsm_transitions
     where ftr_fst_id = p_fsm.fsm_fst_id
       and ftr_fev_id = p_fev_id
       and ftr_fcl_id = p_fsm.fsm_fcl_id;
    if instr(l_next_fst_list, C_DELIMITER) = 0 then
      notify(p_fsm, msg.fsm_NEXT_STATUS_RECOGNIZED, msg_args(l_next_fst_list));
      
      pit.leave_optional(
      p_params => msg_params(
                    msg_param('Next Status', l_next_fst_list)));
      return l_next_fst_list;
    else
      pit.error(msg.fsm_NEXT_STATUS_NU, msg_args(p_fsm.fsm_fst_id), p_fsm.fsm_id);
      return null;
    end if;
  exception
    when no_data_found then
      pit.error(msg.fsm_NEXT_STATUS_NU, msg_args(p_fsm.fsm_fst_id), p_fsm.fsm_id);
      return null;
  end get_next_status;    
  
  
  procedure notify(
    p_fsm in out nocopy fsm_type,
    p_msg in ora_name_type,
    p_msg_args in msg_args)
  as
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_msg', p_msg)));
                    
    log_change(
      p_fsm => p_fsm,
      p_msg => p_msg,
      p_msg_args => p_msg_args);
      
    pit.leave_mandatory;
  end notify;
  
  
  function to_string(
    p_fsm in fsm_type)
    return varchar2
  as
    l_result varchar2(32767) := 
    q'[Instanz vom Typ fsm_TYPE
    fsm_ID: #fsm_ID#
    fsm_fcl_id: #fsm_FCL_ID#
    fsm_fst_id: #fsm_FST_ID#
    fsm_VALIDITY: #fsm_VALIDITY#
    event_list: #FEV_LIST#
]';
  begin
    pit.enter_mandatory;
    
    utl_text.bulk_replace(l_result, char_table(
      '#fsm_ID#', p_fsm.fsm_id,
      '#fsm_FCL_ID#', p_fsm.fsm_fcl_id,
      '#fsm_FST_ID#', p_fsm.fsm_fst_id,
      '#fsm_VALIDITY#', p_fsm.fsm_validity,
      '#FEV_LIST#', p_fsm.fsm_fev_list));
      
    pit.leave_mandatory;
    return l_result;
  end to_string;
  
  
  procedure finalize(
    p_fsm fsm_type)
  as
  begin
    pit.enter_mandatory;
    null;
    pit.leave_mandatory;
  end finalize;

begin
  initialize;
end fsm;
/