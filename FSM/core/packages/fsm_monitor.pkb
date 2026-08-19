create or replace package body fsm_monitor
as
  C_MONITOR_MESSAGE constant pit_util.ora_name_type := msg.FSM_MONITOR_STATUS_CHANGED;

  type monitor_status_rec is record(
    fms_id fsm_monitor_status.fms_id%type,
    fms_sort_seq fsm_monitor_status.fms_sort_seq%type,
    fms_active fsm_monitor_status.fms_active%type);


  /**
    Procedure: load_monitor_status
      Loads one global monitor status definition.

    Parameters:
      p_fms_id - Monitor status identifier
      p_status - Loaded lookup row
   */
  procedure load_monitor_status(
    p_fms_id in fsm_monitor_status.fms_id%type,
    p_status out nocopy monitor_status_rec)
  as
  begin
    select fms_id, fms_sort_seq, fms_active
      into p_status.fms_id, p_status.fms_sort_seq, p_status.fms_active
      from fsm_monitor_status
     where fms_id = p_fms_id;
  end load_monitor_status;


  /**
    Function: get_reference_date
      Determines the timestamp from which escalation intervals are measured.

    Parameters:
      p_escalation_basis - EVENT or STATUS
      p_last_change_date - Last successful activity
      p_status_change_date - Last actual business status change

    Returns:
      Relevant persisted reference date
   */
  function get_reference_date(
    p_escalation_basis in fsm_status.fst_escalation_basis%type,
    p_last_change_date in fsm_objects.fsm_last_change_date%type,
    p_status_change_date in fsm_objects.fsm_status_change_date%type)
    return date
  as
  begin
    return case p_escalation_basis
           when 'EVENT' then p_last_change_date
           else coalesce(p_status_change_date, p_last_change_date)
           end;
  end get_reference_date;


  /**
    Function: get_threshold_date
      Adds an Oracle day-to-second interval to a DATE value.

    Parameters:
      p_reference_date - Escalation reference date
      p_interval - Configured warning or alert interval

    Returns:
      Threshold as DATE, or NULL when either input is NULL
   */
  function get_threshold_date(
    p_reference_date in date,
    p_interval in interval day to second)
    return date
  as
  begin
    if p_reference_date is null or p_interval is null then
      return null;
    end if;

    return cast(cast(p_reference_date as timestamp) + p_interval as date);
  end get_threshold_date;


  /**
    Procedure: write_log
      Records one monitor signal in FSM_LOG using the internationalized PIT
      monitor message.

    Parameters:
      p_fsm_id - Persisted FSM identifier
      p_fsm_fcl_id - FSM class identifier
      p_fsm_fsc_id - FSM subclass identifier
      p_fsm_fst_id - Current business status identifier
      p_fsm_fev_list - Currently allowed events
      p_previous_fms_id - Monitor status before the signal
      p_signaled_fms_id - Monitor status represented by the signal
      p_detected_at - Shared detection timestamp of the scan
   */
  procedure write_log(
    p_fsm_id in fsm_objects.fsm_id%type,
    p_fsm_fcl_id in fsm_objects.fsm_fcl_id%type,
    p_fsm_fsc_id in fsm_objects.fsm_fsc_id%type,
    p_fsm_fst_id in fsm_objects.fsm_fst_id%type,
    p_fsm_fev_list in fsm_objects.fsm_fev_list%type,
    p_previous_fms_id in fsm_monitor_status.fms_id%type,
    p_signaled_fms_id in fsm_monitor_status.fms_id%type,
    p_detected_at in timestamp)
  as
    l_message message_type;
    l_message_args msg_args;
  begin
    l_message_args := msg_args(
                        to_char(p_fsm_id),
                        p_previous_fms_id,
                        p_signaled_fms_id);
    l_message := pit.get_message(
                   p_message_name => C_MONITOR_MESSAGE,
                   p_msg_args => l_message_args,
                   p_affected_id => to_char(p_fsm_id));

    insert into fsm_log(
      fsl_id, fsl_fsm_id, fsl_user_name, fsl_session_id,
      fsl_log_date, fsl_msg_text, fsl_severity,
      fsl_fst_id, fsl_fev_list, fsl_fcl_id, fsl_fsc_id,
      fsl_msg_id, fsl_msg_args)
    values(
      fsm_log_seq.nextval, p_fsm_id, l_message.user_name, l_message.session_id,
      p_detected_at, l_message.message_text, l_message.severity,
      p_fsm_fst_id, p_fsm_fev_list, p_fsm_fcl_id, p_fsm_fsc_id,
      l_message.message_name, pit_util.cast_to_msg_args_char(l_message.message_args));
  end write_log;


  /**
    Procedure: scan
      See: FSM_MONITOR.scan

      The monitor projection and its log signals are committed independently of
      subsequent processing by the invoking application schema.
   */
  procedure scan(
    p_fcl_id in fsm_classes.fcl_id%type,
    p_scan_date in date default sysdate,
    p_findings out nocopy finding_tab)
  as
    pragma autonomous_transaction;

    cursor object_cur is
      select obj.fsm_id, obj.fsm_fcl_id, obj.fsm_fsc_id, obj.fsm_fst_id,
             obj.fsm_fev_list, obj.fsm_last_change_date,
             obj.fsm_status_change_date, obj.fsm_fms_id,
             old_fms.fms_sort_seq old_sort_seq,
             fst.fst_warn_interval, fst.fst_alert_interval,
             fst.fst_escalation_basis
        from fsm_objects obj
        join fsm_status fst
          on obj.fsm_fst_id = fst.fst_id
         and obj.fsm_fcl_id = fst.fst_fcl_id
        join fsm_monitor_status old_fms
          on obj.fsm_fms_id = old_fms.fms_id
       where obj.fsm_fcl_id = p_fcl_id;

    l_ok monitor_status_rec;
    l_warn monitor_status_rec;
    l_alert monitor_status_rec;
    l_current monitor_status_rec;
    l_reference_date date;
    l_warn_date date;
    l_alert_date date;
    l_monitor_status_date date;
    l_signal_from fsm_monitor_status.fms_id%type;
    l_scan_date date := coalesce(p_scan_date, sysdate);
    l_detected_at timestamp := cast(l_scan_date as timestamp);

    /**
      Procedure: add_finding
        Appends one signal to the result collection and writes its FSM_LOG entry.

      Parameters:
        p_object - Persisted FSM row selected by the scan
        p_previous_fms_id - Monitor status before this signal
        p_signaled_fms_id - Monitor status represented by this signal
        p_current_fms_id - Final monitor status calculated by the scan
        p_monitor_status_date - Effective date of the signaled monitor status
     */
    procedure add_finding(
      p_object in object_cur%rowtype,
      p_previous_fms_id in fsm_monitor_status.fms_id%type,
      p_signaled_fms_id in fsm_monitor_status.fms_id%type,
      p_current_fms_id in fsm_monitor_status.fms_id%type,
      p_monitor_status_date in date)
    as
      l_index binary_integer;
    begin
      l_index := p_findings.count + 1;
      p_findings(l_index).fsm_id := p_object.fsm_id;
      p_findings(l_index).fsm_fcl_id := p_object.fsm_fcl_id;
      p_findings(l_index).fsm_fsc_id := p_object.fsm_fsc_id;
      p_findings(l_index).previous_fms_id := p_previous_fms_id;
      p_findings(l_index).signaled_fms_id := p_signaled_fms_id;
      p_findings(l_index).current_fms_id := p_current_fms_id;
      p_findings(l_index).monitor_status_date := p_monitor_status_date;
      p_findings(l_index).detected_at := l_detected_at;

      write_log(
        p_fsm_id => p_object.fsm_id,
        p_fsm_fcl_id => p_object.fsm_fcl_id,
        p_fsm_fsc_id => p_object.fsm_fsc_id,
        p_fsm_fst_id => p_object.fsm_fst_id,
        p_fsm_fev_list => p_object.fsm_fev_list,
        p_previous_fms_id => p_previous_fms_id,
        p_signaled_fms_id => p_signaled_fms_id,
        p_detected_at => l_detected_at);
    end add_finding;
  begin
    pit.enter_mandatory('scan',
      p_params => msg_params(
                    msg_param('p_fcl_id', p_fcl_id),
                    msg_param('p_scan_date', to_char(l_scan_date, 'YYYY-MM-DD HH24:MI:SS'))));

    p_findings.delete;
    load_monitor_status(C_OK, l_ok);
    load_monitor_status(C_WARN, l_warn);
    load_monitor_status(C_ALERT, l_alert);

    for obj in object_cur loop
      l_reference_date := get_reference_date(
                            obj.fst_escalation_basis,
                            obj.fsm_last_change_date,
                            obj.fsm_status_change_date);
      l_warn_date := get_threshold_date(l_reference_date, obj.fst_warn_interval);
      l_alert_date := get_threshold_date(l_reference_date, obj.fst_alert_interval);

      case
      when l_alert.fms_active = pit_util.C_TRUE
       and l_alert_date is not null
       and l_scan_date >= l_alert_date
      then
        l_current := l_alert;
        l_monitor_status_date := l_alert_date;
      when l_warn.fms_active = pit_util.C_TRUE
       and l_warn_date is not null
       and l_scan_date >= l_warn_date
      then
        l_current := l_warn;
        l_monitor_status_date := l_warn_date;
      else
        l_current := l_ok;
        l_monitor_status_date := l_scan_date;
      end case;

      if l_current.fms_id != obj.fsm_fms_id then
        l_signal_from := obj.fsm_fms_id;

        if l_current.fms_sort_seq > obj.old_sort_seq then
          for status_rec in (
            select fms_id
              from fsm_monitor_status
             where fms_active = pit_util.C_TRUE
               and fms_sort_seq > obj.old_sort_seq
               and fms_sort_seq <= l_current.fms_sort_seq
             order by fms_sort_seq)
          loop
            add_finding(
              p_object => obj,
              p_previous_fms_id => l_signal_from,
              p_signaled_fms_id => status_rec.fms_id,
              p_current_fms_id => l_current.fms_id,
              p_monitor_status_date => case status_rec.fms_id
                                       when C_WARN then l_warn_date
                                       when C_ALERT then l_alert_date
                                       else l_monitor_status_date
                                       end);
            l_signal_from := status_rec.fms_id;
          end loop;
        else
          add_finding(
            p_object => obj,
            p_previous_fms_id => obj.fsm_fms_id,
            p_signaled_fms_id => l_current.fms_id,
            p_current_fms_id => l_current.fms_id,
            p_monitor_status_date => l_monitor_status_date);
        end if;

        update fsm_objects
           set fsm_fms_id = l_current.fms_id,
               fsm_monitor_status_date = l_monitor_status_date
         where fsm_id = obj.fsm_id;
      end if;
    end loop;

    pit.leave_mandatory(
      p_params => msg_params(
                    msg_param('finding_count', p_findings.count)));
    commit;
  exception
    when others then
      rollback;
      pit.handle_exception(msg.PIT_SQL_ERROR);
  end scan;
end fsm_monitor;
/
