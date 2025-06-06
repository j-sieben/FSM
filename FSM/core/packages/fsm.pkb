create or replace package body fsm
as
  /**
    Package: FSM Body
      Implementation of the FSM package

    Author::
      Juergen Sieben, ConDeS GmbH

      Published under MIT licence
   */

  /**
    Group: Private methods
   */
  /*
    Procedure: persist_retry
      Method persists retry of a FSM instance to achieve a new status.
      Is called when a FSM instance could not achieve a new status and retries to reach it.

    Parameters:
      p_fsm - FSM instance
      p_retry_schedule - Schedule to be used for the next retry
   */
  procedure persist_retry(
    p_fsm in out nocopy fsm_type,
    p_retry_schedule in fsm_objects.fsm_retry_schedule%type)
  as
    pragma autonomous_transaction;
  begin
    pit.enter_detailed('persist_retry',
      p_params => msg_params(
                    msg_param('p_fsm', p_fsm.fsm_id),
                    msg_param('p_retry_schedule', p_retry_schedule)));

    update fsm_objects
       set fsm_validity = p_fsm.fsm_validity,
           fsm_retry_schedule = p_retry_schedule
     where fsm_id = p_fsm.fsm_id;
    commit;

    pit.leave_detailed;
  end persist_retry;


  /*
    Procedure:re_fir_event
      Method tries to re-fire an event that has not succeeded before.

    Parameters:
      p_fsm - FSM instance
      p_fev_id - Event to raise
      p_wait_time - wait time after which the event is raised
      p_try_count - Counter that counts the amount of tries
   */
  procedure re_fire_event(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events_v.fev_id%type,
    p_wait_time in fsm_status.fst_retry_time%type,
    p_try_count in fsm_status.fst_retries_on_error%type)
  as
    l_result binary_integer;
  begin
    pit.enter_optional('re_fire_event',
      p_params => msg_params(
                    msg_param('p_fsm', p_fsm.fsm_id),
                    msg_param('p_fev_id', p_fev_id),
                    msg_param('p_wait_time', p_wait_time),
                    msg_param('p_try_count', p_try_count)));

    if p_wait_time is not null then
      pit.raise_info(
        msg.FSM_RETRYING,
        msg_args(
          p_fev_id,
          p_fsm.fsm_fst_id,
          p_fsm.fsm_fev_list,
          to_char(p_try_count)),
          p_fsm.fsm_id);
      -- Wait and retry status change
      dbms_session.sleep(p_wait_time);
      l_result := p_fsm.raise_event(p_fev_id);
    end if;

    pit.leave_optional;
  end re_fire_event;


  /*
    Procedure: proceed_with_error_event
      Method stops retriggering an event and sets the instance to error status.
      As no retry is allowed, the method examines the metadata to find transitions
      that have to be executed in case of error.
      If no transition is found, it will use a generic FSM_ERROR event.

    Parameters:
      p_fsm - FSM instance
   */
  procedure proceed_with_error_event(
    p_fsm in out nocopy fsm_type)
  as
    l_result binary_integer;
    l_event fsm_events_v.fev_id%type;
  begin
    pit.enter_optional('proceed_with_error_event',
      p_params => msg_params(
                    msg_param('p_fsm', p_fsm.fsm_id)));
    pit.raise_verbose(
      msg.FSM_VALIDITY,
      msg_args(
        to_char(p_fsm.fsm_validity)),
        p_fsm.fsm_id);
    select ftr_fev_id
      into l_event
      from fsm_transitions
     where ftr_fst_id = p_fsm.fsm_fst_id
       and ftr_fcl_id = p_fsm.fsm_fcl_id
       and ftr_raise_on_status = 1;
    pit.raise_verbose(msg.FSM_THROW_ERROR_EVENT, msg_args(l_event), p_fsm.fsm_id);

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


  /*
    Procedure: log_change
      Method to maintain FSM_LOG. Called to log status changes, events and notifications from FSM

    Parameters:
      p_fsm - FSM instance
      p_fev_id - Optional event that was triggered
      p_fst_id - Optional new status that was taken
      p_msg - Optional ID of a message from PIT
      p_msg_args - Optional MSG_ARGS instance with message parameters
   */
  procedure log_change(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events_v.fev_id%type default null,
    p_fst_id in fsm_status.fst_id%type default null,
    p_msg in varchar2 default null,
    p_msg_args in msg_args default null)
  as
    l_message message_type;
    l_message_id fsm_events_v.fev_msg_id%type;
    l_user pit_util.ora_name_type;
    l_msg_args msg_args;
  begin
    pit.enter_optional('log_change',
      p_params => msg_params(
                    msg_param('p_fsm', p_fsm.fsm_id),
                    msg_param('p_fev_id', p_fev_id),
                    msg_param('p_fst_id', p_fst_id),
                    msg_param('p_msg', p_msg),
                    msg_param('p_msg_args', p_msg_args)));

    -- choose appropriate message based on parameters entered

    case
    when p_msg is not null then
      l_message_id := p_msg;
      l_msg_args := case p_msg_args.count when 0 then null else p_msg_args end;
    when p_fev_id is not null then
      select fev_msg_id, msg_args(fev_name)
        into l_message_id, l_msg_args
        from fsm_events_v
       where fev_id = p_fev_id
         and fev_fcl_id = p_fsm.fsm_fcl_id;
    when p_fst_id = fsm_fst.FSM_ERROR then
      select msg.FSM_DELIVERY_FAILED, msg_args(fst_name)
        into l_message_id, l_msg_args
        from fsm_status_v
       where fst_id = p_fst_id
         and fst_fcl_id = p_fsm.fsm_fcl_id;
    when p_fst_id is not null then
      select fst_msg_id, coalesce(p_msg_args, msg_args(fst_name))
        into l_message_id, l_msg_args
        from fsm_status_v
       where fst_id = p_fst_id
         and fst_fcl_id = p_fsm.fsm_fcl_id;
    else
      null;
    end case;

    -- create message
    l_message := pit.get_message(
                   p_message_name => l_message_id,
                   p_msg_args => l_msg_args,
                   p_affected_id => to_char(p_fsm.fsm_id));

    -- LOG
    insert into fsm_log(
      fsl_id, fsl_fsm_id, fsl_user_name, fsl_session_id,
      fsl_log_date, fsl_msg_text, fsl_severity,
      fsl_fst_id, fsl_fev_list, fsl_fcl_id,
      fsl_msg_id, fsl_msg_args)
    values(
      fsm_log_seq.nextval, to_number(l_message.affected_id), l_message.user_name, l_message.session_id,
      current_timestamp, l_message.message_text, l_message.severity,
      p_fsm.fsm_fst_id, p_fsm.fsm_fev_list, p_fsm.fsm_fcl_id,
      l_message.message_name, pit_util.cast_to_msg_args_char(l_message.message_args));

    pit.leave_optional(
      p_params => msg_params(
                    msg_param('Message', l_message.message_text)));
  end log_change;


  /**
    Group: Interface
   */
  /*
    Procedure: drop_object
      See  <FSM.drop_object>
   */
  procedure drop_object(
    p_fsm_id in fsm_objects_v.fsm_id%type)
  as
  begin
    pit.enter_mandatory('drop_object',
      p_params => msg_params(
                    msg_param('p_fsm_id', p_fsm_id)));

    delete from fsm_objects
     where fsm_id = p_fsm_id;

    pit.leave_mandatory;
  end drop_object;


  /*
    Procedure: lock_fsm
      See  <FSM.lock_fsm>
   */
  procedure lock_fsm(
    p_fsm_id in out nocopy fsm_objects.fsm_id%type)
  as
  begin
    pit.enter_mandatory('lock_fsm',
      p_params => msg_params(
                    msg_param('p_fsm_id', p_fsm_id)));

    select fsm_id
      into p_fsm_id
      from fsm_objects
     where fsm_id = p_fsm_id
       for update;

    pit.leave_mandatory;
  exception
    when NO_DATA_FOUND then
      pit.leave_mandatory;
  end lock_fsm;


  /*
    Procedure: persist
      See  <FSM.persist>
   */
  procedure persist(
    p_fsm in out nocopy fsm_type)
  as
  begin
    pit.enter_mandatory('persist',
      p_params => msg_params(
                    msg_param('p_fsm', p_fsm.fsm_id)));

    p_fsm.fsm_id := coalesce(p_fsm.fsm_id, fsm_seq.nextval);
    merge into fsm_objects t
    using (select p_fsm.fsm_id fsm_id,
                  p_fsm.fsm_fcl_id fsm_fcl_id,
                  p_fsm.fsm_fst_id fsm_fst_id,
                  coalesce(p_fsm.fsm_validity, C_OK) fsm_validity,
                  p_fsm.fsm_fev_list fsm_fev_list,
                  sysdate fsm_last_change_date
             from dual) s
       on (t.fsm_id = s.fsm_id)
     when matched then update set
          t.fsm_fst_id = s.fsm_fst_id,
          t.fsm_validity = s.fsm_validity,
          t.fsm_fev_list = s.fsm_fev_list,
          t.fsm_last_change_date = s.fsm_last_change_date
     when not matched then insert(fsm_id, fsm_fcl_id, fsm_fst_id, fsm_validity, fsm_fev_list, fsm_last_change_date)
          values(s.fsm_id, s.fsm_fcl_id, s.fsm_fst_id, s.fsm_validity, s.fsm_fev_list, s.fsm_last_change_date);

    pit.leave_mandatory;
  end persist;


  /*
    Function: raise_event
      See  <FSM.raise_event>
   */
  function raise_event(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events_v.fev_id%type,
    p_msg in pit_util.ora_name_type default null,
    p_msg_args in msg_args default null)
    return integer
  as
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_fsm', p_fsm.fsm_id),
                    msg_param('fsm_fst_id', p_fsm.fsm_fst_id),
                    msg_param('p_fev_id', p_fev_id)));

    lock_fsm(p_fsm.fsm_id);
    -- LOG verwalten
    log_change(
      p_fsm => p_fsm,
      p_fev_id => p_fev_id,
      p_msg => p_msg,
      p_msg_args => p_msg_args);
    p_fsm.fsm_validity := C_OK;

    pit.leave_mandatory(
      p_params => msg_params(
                    msg_param('Status', C_OK)));
    return C_OK;
  exception
    when others then
      pit.handle_exception(msg.FSM_SQL_ERROR, msg_args(p_fsm.fsm_fcl_id, to_char(p_fsm.fsm_id), p_fev_id));
      return C_ERROR;
  end raise_event;


  /*
    Procedure: retry
      See  <FSM.retry>
   */
  procedure retry(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events_v.fev_id%type)
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
         and fsm.fsm_validity != fsm.C_ERROR;
    l_validity fsm_objects.fsm_validity%type;
  begin
    pit.enter_mandatory('retry',
      p_params => msg_params(
                    msg_param('p_fsm', p_fsm.fsm_id),
                    msg_param('fsm_fst_id', p_fsm.fsm_id),
                    msg_param('p_fev_id', p_fev_id)));

    for fsm in fsm_cur(p_fsm.fsm_id) loop
      if fsm.fst_retries_on_error > C_ERROR then
        pit.raise_verbose(msg.FSM_RETRY_REQUESTED, msg_args(p_fev_id, fsm.fst_id, pit_util.C_TRUE), p_fsm.fsm_id);
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
            p_fsm.notify(msg.FSM_RETRY_INFO);
          else
            p_fsm.notify(msg.FSM_RETRY_WARN);
          end if;
          persist_retry(p_fsm, fsm.fst_retry_schedule);
          l_validity := fsm.fst_retries_on_error - fsm.fsm_validity + 1;
          re_fire_event(p_fsm, p_fev_id, fsm.fst_retry_time, l_validity);
        end case;
      else
        pit.raise_verbose(msg.FSM_RETRY_REQUESTED, msg_args(p_fev_id, fsm.fst_id, pit_util.C_FALSE), p_fsm.fsm_id);
        proceed_with_error_event(p_fsm);
      end if;

    end loop;

    pit.leave_mandatory;
  end retry;


  /*
    Function: allows_event
      See  <FSM.allows_event>
   */
  function allows_event(
    p_fsm in out nocopy fsm_type,
    p_fev_id fsm_events_v.fev_id%type)
    return boolean
  as
    l_result boolean;
    l_has_role binary_integer;
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('p_fsm', p_fsm.fsm_id),
                    msg_param('fsm_fst_id', p_fsm.fsm_fst_id),
                    msg_param('Event list', p_fsm.fsm_fev_list),
                    msg_param('p_fev_id', p_fev_id)));

    -- Check if event is allowed in current state
    l_result := instr(':' || p_fsm.fsm_fev_list || ':ERROR:', ':' || p_fev_id || ':') > 0;

    -- Check if current user has required role rights
    -- TODO: Add role support
    /*select case
           when ftr_required_role is not null then C_ERROR -- auth_user.is_authorized(ftr_required_role)
           else C_OK end
      into l_has_role
      from fsm_transitions
     where ftr_fev_id = p_fev_id
       and ftr_fst_id = p_fsm.fsm_fst_id
       and ftr_fcl_id = p_fsm.fsm_fcl_id;*/

    pit.leave_optional(
      p_params => msg_params(
                    msg_param('result', pit_util.to_bool(l_result))));
    return l_result;-- and l_has_role > C_ERROR;
  exception
    when no_data_found then
      pit.leave_optional;
      return false;
  end allows_event;


  /*
    Function: set_status
      See  <FSM.set_status>
   */
  function set_status(
    p_fsm in out nocopy fsm_type,
    p_msg in pit_util.ora_name_type default null,
    p_msg_args in msg_args default null)
    return number
  as
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('fsm_fst_id', p_fsm.fsm_fst_id)));

    pit.assert_not_null(p_fsm.fsm_fst_id, p_msg_args => msg_args('FSM_FST_ID'));
    p_fsm.fsm_validity := coalesce(p_fsm.fsm_validity, C_OK);

    -- Find out the next possible events
    select listagg(fev_id, ':') within group(order by fev_id) fev_list,
           max(ftr_raise_automatically) event_auto
      into p_fsm.fsm_fev_list,
           p_fsm.fsm_auto_raise
      from bl_fsm_active_status_event
     where fst_id = p_fsm.fsm_fst_id
       and fcl_id = p_fsm.fsm_fcl_id
       and ftr_raise_on_status = p_fsm.fsm_validity;

    persist(p_fsm);

    log_change(
      p_fsm => p_fsm,
      p_fst_id => p_fsm.fsm_fst_id,
      p_msg => p_msg,
      p_msg_args => p_msg_args);

    notify(p_fsm, msg.FSM_NEXT_EVENTS, msg_args(p_fsm.fsm_fev_list, p_fsm.fsm_auto_raise));

    pit.leave_mandatory(
      p_params => msg_params(
                    msg_param('Result', p_fsm.fsm_validity)));
    return p_fsm.fsm_validity;
  exception
    when msg.PIT_ASSERTION_FAILED_ERR then
      if p_fsm.fsm_fst_id != fsm_fst.FSM_ERROR then
        p_fsm.fsm_fst_id := fsm_fst.FSM_ERROR;

        pit.leave_mandatory;
        return set_status(p_fsm);
      else
        pit.leave_mandatory;
        return C_ERROR;
      end if;
    when others then
      pit.handle_exception(msg.PIT_SQL_ERROR);
      if p_fsm.fsm_fst_id != fsm_fst.FSM_ERROR then
        p_fsm.fsm_fst_id := fsm_fst.FSM_ERROR;
        return set_status(p_fsm);
      else
        pit.leave_mandatory;
        return C_ERROR;
      end if;
  end set_status;


  /*
    Procedure: set_status
      See  <FSM.set_status>
   */
  procedure set_status(
    p_fsm in out nocopy fsm_type,
    p_msg in pit_util.ora_name_type default null,
    p_msg_args in msg_args default null)
  as
    l_result binary_integer;
  begin
    l_result := set_status(p_fsm, p_msg, p_msg_args);
  end set_status;


  /*
    Function: get_next_status
      See  <FSM.get_next_status>
   */
  function get_next_status(
    p_fsm in out nocopy fsm_type,
    p_fev_id in fsm_events_v.fev_id%type)
    return varchar2
  as
    l_next_fst_list pit_util.max_sql_char;
    C_DELIMITER constant pit_util.flag_type := ':';
  begin
    pit.enter_optional(
      p_params => msg_params(
                    msg_param('fsm_fst_id', p_fsm.fsm_fst_id),
                    msg_param('p_fev_id', p_fev_id)));

    select listagg(ftr_fst_list, C_DELIMITER) within group (order by ftr_fst_list)
      into l_next_fst_list
      from fsm_transitions
     where ftr_fst_id = p_fsm.fsm_fst_id
       and ftr_fev_id = p_fev_id
       and ftr_fcl_id in (p_fsm.fsm_fcl_id, 'FSM');
    if instr(l_next_fst_list, C_DELIMITER) = 0 then
      notify(p_fsm, msg.FSM_NEXT_STATUS_RECOGNIZED, msg_args(l_next_fst_list));

      pit.leave_optional(
      p_params => msg_params(
                    msg_param('Next Status', l_next_fst_list)));
      return l_next_fst_list;
    else
      pit.raise_error(msg.FSM_NEXT_STATUS_NU, msg_args(p_fsm.fsm_fst_id), p_fsm.fsm_id);
      return null;
    end if;
  exception
    when no_data_found then
      pit.raise_error(msg.FSM_NEXT_STATUS_NU, msg_args(p_fsm.fsm_fst_id), p_fsm.fsm_id);
      return null;
  end get_next_status;


  /*
    Procedure: notify
      See  <FSM.notify>
   */
  procedure notify(
    p_fsm in out nocopy fsm_type,
    p_msg in pit_util.ora_name_type,
    p_msg_args in msg_args default null)
  as
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_fsm', p_fsm.fsm_id),
                    msg_param('p_msg', p_msg),
                    msg_param('p_msg_args', p_msg_args)));

    log_change(
      p_fsm => p_fsm,
      p_msg => p_msg,
      p_msg_args => p_msg_args);

    pit.leave_mandatory;
  end notify;


  /*
    Function: to_string
      See  <FSM.to_string>
   */
  function to_string(
    p_fsm in fsm_type)
    return varchar2
  as
    l_result pit_util.max_char :=
    q'[Instance of type FSM_TYPE
    fsm_ID: #FSM_ID#
    fsm_fcl_id: #FSM_FCL_ID#
    fsm_fst_id: #FSM_FST_ID#
    fsm_VALIDITY: #FSM_VALIDITY#
    event_list: #FEV_LIST#
]';
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_fsm', p_fsm.fsm_id)));

    utl_text.bulk_replace(l_result, char_table(
      'FSM_ID', p_fsm.fsm_id,
      'FSM_FCL_ID', p_fsm.fsm_fcl_id,
      'FSM_FST_ID', p_fsm.fsm_fst_id,
      'FSM_VALIDITY', p_fsm.fsm_validity,
      'FEV_LIST', p_fsm.fsm_fev_list));

    pit.leave_mandatory;
    return l_result;
  end to_string;


  /*
    Procedure: finalize
      See  <FSM.finalize>
   */
  procedure finalize(
    p_fsm fsm_type)
  as
  begin
    pit.enter_mandatory(
      p_params => msg_params(
                    msg_param('p_fsm', p_fsm.fsm_id)));
    null;
    pit.leave_mandatory;
  end finalize;

end fsm;
/