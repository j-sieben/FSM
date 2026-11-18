create or replace package body fsm_event_context as
  pragma serially_reusable;
  type event_tab is table of event_rec index by binary_integer;
  type reason_tab is table of reason_rec index by varchar2(128);
  g_events event_tab;
  g_depth binary_integer := 0;
  g_reasons reason_tab;

  /* Procedure: push_event
     See: <FSM_EVENT_CONTEXT.push_event> */
  procedure push_event(p_event in event_rec) as
  begin
    g_depth := g_depth + 1;
    g_events(g_depth) := p_event;
    g_events(g_depth).retry_confirmed := false;
  end push_event;

  /* Function: current_event
     See: <FSM_EVENT_CONTEXT.current_event> */
  function current_event(p_id number, p_class varchar2, p_subclass varchar2) return event_rec as
  begin
    if g_depth = 0 then
      raise_application_error(-20001, 'FSM write requires an active event context');
    end if;
    if p_id is null or p_class is null or p_subclass is null
       or g_events(g_depth).fsm_id != p_id
       or g_events(g_depth).class_id != p_class
       or g_events(g_depth).subclass_id != p_subclass then
      raise_application_error(-20001, 'FSM event context belongs to another instance');
    end if;
    return g_events(g_depth);
  end current_event;

  /* Function: pop_event
     See: <FSM_EVENT_CONTEXT.pop_event> */
  function pop_event(p_id number, p_class varchar2, p_subclass varchar2) return event_rec as
    l_event event_rec;
  begin
    l_event := current_event(p_id, p_class, p_subclass);
    g_events.delete(g_depth);
    g_depth := g_depth - 1;
    return l_event;
  end pop_event;

  /* Procedure: confirm_retry
     See: <FSM_EVENT_CONTEXT.confirm_retry> */
  procedure confirm_retry(p_id number, p_class varchar2, p_subclass varchar2) as
    l_event event_rec;
  begin
    l_event := current_event(p_id, p_class, p_subclass);
    g_events(g_depth).retry_confirmed := true;
  end confirm_retry;

  /* Function: is_empty
     See: <FSM_EVENT_CONTEXT.is_empty> */
  function is_empty return boolean as
  begin
    return g_depth = 0;
  end is_empty;

  /* Procedure: clear_all
     See: <FSM_EVENT_CONTEXT.clear_all> */
  procedure clear_all as
  begin
    g_events.delete;
    g_depth := 0;
    g_reasons.delete;
  end clear_all;

  /* Procedure: set_reason
     See: <FSM_EVENT_CONTEXT.set_reason> */
  procedure set_reason(p_id number, p_reason reason_rec) as
  begin
    g_reasons(to_char(p_id)) := p_reason;
  end set_reason;

  /* Function: get_reason
     See: <FSM_EVENT_CONTEXT.get_reason> */
  function get_reason(p_id number) return reason_rec as
    l_reason reason_rec;
  begin
    if p_id is not null and g_reasons.exists(to_char(p_id)) then
      l_reason := g_reasons(to_char(p_id));
    end if;
    return l_reason;
  end get_reason;

  /* Procedure: clear_reason
     See: <FSM_EVENT_CONTEXT.clear_reason> */
  procedure clear_reason(p_id number) as
  begin
    if p_id is not null then
      g_reasons.delete(to_char(p_id));
    end if;
  end clear_reason;
end fsm_event_context;
/
