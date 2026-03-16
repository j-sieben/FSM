# FSM Finite State Machine

Lightweight finite-state machine infrastructure for Oracle databases and PL/SQL.

The project is designed as a reusable utility schema. Applications define their own concrete FSM types and local business logic, while the generic runtime, metadata model and logging stay centralized.

## Why Use a Finite-State Machine
A finite-state machine models a process as a small set of well-defined states and explicit transitions between them.

Instead of scattering workflow logic across many flags, timestamps and procedural checks, the process is described in terms of:

- the current state of an object
- the events that may occur in that state
- the allowed target states after such an event

That gives two immediate benefits:

- the current processing stage becomes easy to query
- the allowed next steps become explicit and centrally controlled

This is particularly useful in database-centric systems where processes are long-lived, auditable and shared by multiple applications.

## What It Is
`FSM` provides:

- metadata-driven states, events and transitions
- an abstract runtime type `FSM_TYPE`
- concrete SQL subtypes per business object
- event handling in PL/SQL packages
- centralized logging through PIT
- generated constant packages for statuses and events
- retry, error fallback and status escalation support

This makes it suitable for workflows where:

- more than one business object needs the same state-machine mechanism
- process control should be separated from business data
- workflow state must remain queryable inside the database

## What It Is Not
`FSM` is not:

- a BPMN engine
- a graphical workflow modeler
- a generic rule engine
- a no-code process framework

The state graph is data-driven, but the business decision logic remains in PL/SQL.

## Core Concepts
The runtime is built around the abstract type `FSM_TYPE`. Concrete types inherit from it and implement the business-specific behavior through packages.

For readers who do not work with Oracle object types every day, the relevant point is this:

- `FSM_TYPE` is the generic base contract
- a concrete subtype such as `FSM_REQ_TYPE` represents one business-specific FSM implementation
- the subtype itself is usually thin and delegates its work to a package

The object type is therefore not used as an object-oriented domain model in the broad sense. It is mainly used to express inheritance and to give the runtime a stable, typed contract.

The main metadata tables are:

- `FSM_CLASSES`
- `FSM_STATUS`
- `FSM_EVENT`
- `FSM_TRANSITIONS`

The main runtime tables are:

- `FSM_OBJECTS`
- `FSM_LOG`

## Escalation Support
Statuses may define two expected durations:

- `FST_WARN_INTERVAL`
- `FST_ALERT_INTERVAL`

The comparison basis is configured in `FST_ESCALATION_BASIS`:

- `STATUS`: compare `sysdate` to the last status change
- `EVENT`: compare `sysdate` to the last activity/event

The runtime uses two timestamps in `FSM_OBJECTS`:

- `FSM_LAST_CHANGE_DATE`: last relevant activity or event
- `FSM_STATUS_CHANGE_DATE`: last actual status change

This allows the framework to distinguish between:

- a process that remains in the same state but still emits progress or heartbeat events
- a process that remains in the same state and has become silent

This supports both common cases:

- an object should leave a status within an expected time
- an object remains in a status but must emit heartbeat or progress events

`FSM_OBJECTS_V` exposes the derived state as `STATUS_STATE` with values `OK`, `WARN` or `ALERT`.

This turns the FSM into more than a pure transition engine. It also becomes a monitoring aid for stalled or silent processes.

## Error Handling and Retry
The runtime has a controlled failure path:

- invalid events are treated as errors
- `SET_STATUS` falls back to `FSM_ERROR` if normal processing fails
- if even that path cannot be executed, a hard fallback forces the object into `FSM_ERROR`

Retries persist the failed event and retry schedule in `FSM_OBJECTS`. The current implementation performs retries synchronously.

The important design decision here is that the framework tries to leave an object in a deterministic technical state, even when business logic, metadata or follow-up transitions fail.

## Visibility of Concrete FSM Classes
Concrete classes are linked to their implementing SQL subtype via `FSM_CLASSES.FCL_TYPE_NAME`.

Visibility is derived from Oracle type privileges:

- a class is visible if its implementing type is visible in `ALL_TYPES`
- visibility can be delegated with `EXECUTE` on the concrete type
- the base class `FSM` remains globally visible

This means that applications only see the FSM classes whose implementing types are available to them.

That visibility model is intentionally based on Oracle privileges instead of a second custom authorization model inside the FSM metadata.

## Design Approach
The project deliberately uses SQL object inheritance only where it adds value:

- `FSM_TYPE` defines a stable contract
- concrete subtypes bind the runtime to a specific business domain
- the actual implementation lives in packages

This keeps the object bodies simple and allows the package layer to use private procedures, helper functions and better structured PL/SQL.

For non-trivial processes, the recommended split is:

- `FSM` core package: generic runtime behavior
- concrete `FSM_*` package: event orchestration and persistence
- local `BL_*` package: business decisions and domain logic

That split matters because decision logic and state-machine control are not the same thing:

- the business layer decides what happened
- the FSM layer decides how that result is represented as a state transition

## Dependencies
- [PIT](https://github.com/j-sieben/PIT) is required for logging and assertions.
- [UTL_TEXT](https://github.com/j-sieben/UTL_TEXT) is used by `FSM_ADMIN` for code generation.

## Documentation
- Overview: [Doc/Overview.md](Doc/Overview.md)
- Detailed walkthrough: [Doc/How_it_works.md](Doc/How_it_works.md)

## Disclaimer
This code is YOYO software. You may use, modify and redistribute it freely. No support commitment is implied.
