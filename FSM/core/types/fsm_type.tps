create or replace type fsm_type force
authid definer
as object(
  /**
    Type: FSM_TYPE
      Abstract base type for FSM instances.

      Status changes are orchestrated by <FSM.set_status>. Concrete subtypes may
      override the lifecycle methods below to add class-specific behavior. The
      methods are called synchronously in this order:

      1. <leave_status> - Called before leaving the current status, but only if
         an existing status actually changes.
      2. <before_transition> - Called for every transition, before the new state
         and the subtype-specific attributes are persisted.
      3. <persist_state> - Called after FSM has persisted the common attributes.
         The subtype persists its own attributes here.
      4. <enter_status> - Called after persistence and logging, but only if the
         status actually changed.
      5. <after_transition> - Called after entering the new status for every
         transition.

      After these lifecycle methods, FSM notifies observers about the allowed
      next events. If one of these events is configured as automatic, it is
      raised synchronously. Its resulting status change runs through the same
      sequence recursively. Control returns to the original caller, including a
      constructor that called <FSM.initialize>, after the automatic event chain
      reaches a stable status. Terminal instances are finalized; the completed
      transition chain is committed before <FSM.initialize> returns.
   */
  fsm_id number,
  fsm_fcl_id &ORA_NAME_TYPE.,
  fsm_fsc_id &ORA_NAME_TYPE.,
  fsm_fst_id &ORA_NAME_TYPE.,
  fsm_old_fst_id &ORA_NAME_TYPE.,
  fsm_fev_id &ORA_NAME_TYPE.,
  fsm_validity number,
  fsm_fev_list varchar2(4000 byte),
  fsm_auto_raise &FLAG_TYPE.,
  member function get_actual_status
    return varchar2,
  member function get_next_event_list
    return varchar2,
  member function get_validity
    return varchar2,
  member function raise_event(
    self in out nocopy fsm_type,
    p_fev_id in varchar2,
    p_msg in varchar2 default null,
    p_msg_args in msg_args default null)
    return number,
  member procedure retry(
    self in out nocopy fsm_type,
    p_fev_id in varchar2),
  member function set_status(
    self in out nocopy fsm_type,
    p_fst_id in varchar2,
    p_msg in varchar2 default null,
    p_msg_args in msg_args default null)
    return number,
  /**
    Procedure: leave_status
      Lifecycle hook called immediately before an existing status is left.
      It is skipped for initial entry and when the target status equals the
      current status.
   */
  member procedure leave_status(
    self in out nocopy fsm_type),
  /**
    Procedure: before_transition
      Lifecycle hook called before common and subtype-specific state is
      persisted. It runs for initial entry and unchanged-status transitions as
      well as for regular status changes.
   */
  member procedure before_transition(
    self in out nocopy fsm_type),
  /**
    Procedure: persist_state
      Lifecycle hook called after FSM has persisted the common FSM attributes.
      Concrete subtypes persist their own attributes here. Implementations must
      not commit because FSM owns the transaction for the complete transition
      chain.
   */
  member procedure persist_state(
    self in out nocopy fsm_type),
  /**
    Procedure: enter_status
      Lifecycle hook called after persistence and logging when the target status
      differs from the previous status. It is also called for the initial entry.
   */
  member procedure enter_status(
    self in out nocopy fsm_type),
  /**
    Procedure: after_transition
      Lifecycle hook called after <enter_status>, or directly after logging when
      the status did not change. Automatic events are raised only after this
      hook has returned.
   */
  member procedure after_transition(
    self in out nocopy fsm_type),
  member procedure notify(
    self in out nocopy fsm_type,
    p_msg in varchar2,
    p_msg_args in msg_args default null),
  member procedure log_reason(
    self in out nocopy fsm_type,
    p_reason_code in varchar2,
    p_msg_args in msg_args default null),
  /**
    Procedure: log_reason
      Stores a fully resolved PIT message as transient runtime reason for the
      next successful FSM log entry. Unlike the string overload, the fully
      qualified message ID is not prefixed with the FSM class. Both
      message_name and message_args are preserved unchanged until the next
      successful <FSM.log_change> writes and clears the reason context.

    Parameters:
      p_reason - Fully resolved PIT message to preserve unchanged
   */
  member procedure log_reason(
    self in out nocopy fsm_type,
    p_reason in message_type),
  member function to_string
    return varchar2,
  member procedure finalize(
    self in out nocopy fsm_type)
) not instantiable not final;
/
