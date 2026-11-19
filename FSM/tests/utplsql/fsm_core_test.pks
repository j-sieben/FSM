create or replace package fsm_core_test as
  --%suite(FSM runtime core)
  --%suitepath(fsm)

  --%beforeall
  procedure create_metadata;

  --%afterall
  procedure remove_metadata;

  --%beforeeach
  procedure reset_fixture;

  --%test(Initialization persists the initial status and allowed event)
  procedure initialize_instance;

  --%test(Status transition follows the lifecycle contract)
  procedure transition_lifecycle;

  --%test(An unchanged status skips all transition hooks)
  procedure unchanged_status;

  --%test(An unchanged child without self-transition restores the parent context)
  procedure unchanged_child;

  --%test(Automatic events complete synchronously and finalize)
  procedure automatic_event_chain;

  --%test(Terminal transition invokes finalization)
  procedure terminal_transition;

  --%test(Unknown instance has no escalation state)
  procedure unknown_escalation_state;

  --%test(Direct SET_STATUS is rejected without an event context)
  procedure invalid_status_fallback;

  --%test(Unchanged status preserves activity and status dates)
  procedure activity_timestamp;

  --%test(Status transition updates activity and status dates)
  procedure transition_timestamps;

  --%test(Missing next status raises the deterministic metadata error)
  --%throws(-20889)
  procedure missing_next_status;

  --%test(Ambiguous next status raises the deterministic metadata error)
  --%throws(-20889)
  procedure ambiguous_next_status;

  --%test(Retry re-executes an event successfully)
  procedure retry_succeeds;

  --%test(Exhausted retry follows the configured error transition)
  procedure retry_exhausted;

  --%test(Ambiguous error handling propagates its technical error)
  procedure hard_fallback;

  --%test(Terminal status without outgoing transition is valid metadata)
  procedure terminal_metadata_valid;

  --%test(Metadata without an initial status is rejected)
  procedure missing_initial_rejected;
end fsm_core_test;
/
