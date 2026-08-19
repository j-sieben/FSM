create or replace package fsm_monitor
  authid definer
as
  /**
    Package: FSM_MONITOR
      Detects monitor status changes for persisted FSM instances without
      instantiating their concrete SQL object types. The package persists the
      current monitor status in FSM_OBJECTS and records every detected signal in
      FSM_LOG. Consuming schemas remain responsible for local reactions.

    Transaction behavior:
      SCAN uses an autonomous transaction. A detected signal remains persisted
      even if a consuming schema later rolls back or ignores the returned finding.
   */

  C_OK constant fsm_monitor_status.fms_id%type := 'OK';
  C_WARN constant fsm_monitor_status.fms_id%type := 'WARN';
  C_ALERT constant fsm_monitor_status.fms_id%type := 'ALERT';

  type finding_rec is record(
    fsm_id fsm_objects.fsm_id%type,
    fsm_fcl_id fsm_objects.fsm_fcl_id%type,
    fsm_fsc_id fsm_objects.fsm_fsc_id%type,
    previous_fms_id fsm_monitor_status.fms_id%type,
    signaled_fms_id fsm_monitor_status.fms_id%type,
    current_fms_id fsm_monitor_status.fms_id%type,
    monitor_status_date fsm_objects.fsm_monitor_status_date%type,
    detected_at fsm_log.fsl_log_date%type);

  type finding_tab is table of finding_rec index by binary_integer;

  /**
    Procedure: scan
      Evaluates all persisted FSM instances of one class at a shared point in
      time. Newly crossed active monitor levels are returned in ascending severity
      order. A downward movement returns the newly current level, including OK.
      Unchanged monitor states do not produce findings.

    Parameters:
      p_fcl_id - FSM class to evaluate
      p_scan_date - Shared evaluation and detection time; defaults to SYSDATE
      p_findings - Detected monitor signals in their processing order

    Side effects:
      Updates FSM_OBJECTS, inserts one FSM_LOG row per finding, and commits these
      changes in an autonomous transaction before returning.
   */
  procedure scan(
    p_fcl_id in fsm_classes.fcl_id%type,
    p_scan_date in date default sysdate,
    p_findings out nocopy finding_tab);
end fsm_monitor;
/
