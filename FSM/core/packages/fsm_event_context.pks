create or replace package fsm_event_context
  authid definer
  accessible by (fsm)
as
  pragma serially_reusable;
  /**
    Package: FSM_EVENT_CONTEXT
      Internal per-server-call event stack and pending log reasons. Only FSM may
      access it. Contains no transaction statements, PIT parameter lookup, SQL
      object instances or session-lifetime state. Not a client API.
   */
  type event_rec is record(
    fsm_id number,
    class_id varchar2(128),
    subclass_id varchar2(128),
    event_id varchar2(128),
    previous_event varchar2(128),
    previous_status varchar2(128),
    initializing boolean,
    retry_confirmed boolean);
  type reason_rec is record(reason_msg_id varchar2(128), reason_msg_args msg_args);

  /**
    Procedure: push_event
      Pushes one admitted event or internal initialization frame.
    Parameters:
      p_event - Complete identity, event, parent attributes and initialization flag.
   */
  procedure push_event(p_event in event_rec);

  /**
    Function: current_event
      Validates the top frame and returns it without changing the stack.
    Parameters:
      p_id - FSM identity.
      p_class - FSM class.
      p_subclass - FSM subclass.
    Returns:
      Top event frame.
    Raises:
      -20001 if no matching active frame exists.
   */
  function current_event(p_id number, p_class varchar2, p_subclass varchar2) return event_rec;

  /**
    Function: pop_event
      Validates and removes the top frame. Does not commit or clear other frames.
    Parameters:
      p_id - FSM identity.
      p_class - FSM class.
      p_subclass - FSM subclass.
    Returns:
      Removed frame for restoration of parent attributes.
    Raises:
      -20001 if no matching active frame exists.
   */
  function pop_event(p_id number, p_class varchar2, p_subclass varchar2) return event_rec;

  /**
    Procedure: confirm_retry
      Marks the current frame after retry or modeled error state was persisted.
    Parameters:
      p_id - FSM identity.
      p_class - FSM class.
      p_subclass - FSM subclass.
    Raises:
      -20001 if no matching frame exists. Does not pop or commit.
   */
  procedure confirm_retry(p_id number, p_class varchar2, p_subclass varchar2);

  /**
    Function: is_empty
      Returns TRUE if the stack contains no events. Does not inspect database locks.
   */
  function is_empty return boolean;

  /**
    Procedure: clear_all
      Drops all event frames and reasons after a technical failure. Server-call
      completion also discards all state, independently of transaction outcome.
   */
  procedure clear_all;

  /**
    Procedure: set_reason
      Stores a pending reason until successful log persistence or call completion.
    Parameters:
      p_id - FSM identity.
      p_reason - Message key and unchanged message arguments.
   */
  procedure set_reason(p_id number, p_reason reason_rec);

  /**
    Function: get_reason
      Returns the pending reason or an empty record without creating an entry.
    Parameters:
      p_id - FSM identity.
   */
  function get_reason(p_id number) return reason_rec;

  /**
    Procedure: clear_reason
      Removes one pending reason after successful log persistence.
    Parameters:
      p_id - FSM identity.
   */
  procedure clear_reason(p_id number);
end fsm_event_context;
/
