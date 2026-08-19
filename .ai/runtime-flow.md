# Runtime flow map

## Normal event path

```mermaid
sequenceDiagram
  participant Caller
  participant Concrete as Concrete FSM subtype/package
  participant Core as FSM package
  participant Meta as Transition metadata
  participant Obj as FSM_OBJECTS
  participant Log as FSM_LOG / PIT

  Caller->>Concrete: raise_event(event)
  Concrete->>Core: validate / dispatch event
  Core->>Meta: check allowed transition
  Concrete->>Concrete: execute domain decision
  Concrete->>Core: set_status(target)
  Core->>Obj: lock and persist state/activity
  Core->>Log: record transition/reason
  Core->>Meta: resolve optional automatic event
  Core-->>Concrete: resulting status / validity
  Concrete-->>Caller: result
```

The detailed implementation lives primarily in `FSM/core/packages/fsm.pkb`; the overridable contract and hooks are in `FSM/core/types/fsm_type.tps`.

## Failure and retry branches

```mermaid
flowchart TD
  Event[Incoming event] --> Allowed{Allowed by metadata?}
  Allowed -- yes --> Handler[Concrete handler / business logic]
  Allowed -- no --> Error[Controlled error path]
  Handler --> Outcome{Successful outcome?}
  Outcome -- yes --> Persist[Persist status or activity timestamp]
  Outcome -- retry --> Retry[Persist failed event and retry schedule]
  Outcome -- no --> Error
  Error --> ErrorTransition{FSM_ERROR transition works?}
  ErrorTransition -- yes --> PersistError[Persist FSM_ERROR]
  ErrorTransition -- no --> HardFallback[Force deterministic FSM_ERROR]
  Persist --> Log[Log movement]
  Retry --> Log
  PersistError --> Log
  HardFallback --> Log
```

## Escalation time model

- `FSM_LAST_CHANGE_DATE` represents relevant activity/event time.
- `FSM_STATUS_CHANGE_DATE` changes only when the status changes.
- A status with escalation basis `EVENT` measures silence; basis `STATUS` measures time spent in the status.
- A local job calls `FSM_MONITOR.SCAN` for one class.
- The scan compares the calculated state with the persisted monitor state in `FSM_OBJECTS`.
- Each newly crossed upward state is returned and logged; a downward movement returns and logs the new current state, including `OK`.
- `FSM_OBJECTS_V.STATUS_STATE` exposes the last monitor state persisted by a scan.
- The scan operates in an autonomous transaction, so later local signal handling cannot roll back the detected state or its log entry.
