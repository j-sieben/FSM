# FSM Overview

## Purpose
`FSM` is a lightweight finite-state machine for Oracle databases. It is designed as a reusable utility schema that provides:

- metadata-driven states, events and transitions
- a common runtime engine for concrete FSM implementations
- logging, retries and error handling
- generated constant packages for status and event identifiers

It is intentionally not a BPMN engine and not a generic rule engine. Process control remains in PL/SQL, while the allowed state graph is stored as metadata.

The central idea is simple: instead of deriving the lifecycle of a business object from many procedural checks, the lifecycle is made explicit. An object is always in exactly one status, and only a defined set of events may move it forward.

## Architecture
The implementation is split into three layers:

- core metadata and runtime engine in schema `FSM`
- concrete SQL subtypes such as `FSM_REQ_TYPE`
- local event-handler and business-logic packages for each concrete FSM

The abstract base type `FSM_TYPE` defines the common contract. Concrete subtypes inherit from it and override `RAISE_EVENT` and `SET_STATUS`. The actual logic is implemented in packages, not in the type bodies.

This pattern uses Oracle object types in a deliberately limited way:

- not to model the entire business domain as objects
- but to express a stable interface with inheritance

That matters because PL/SQL packages alone cannot provide the same inheritance mechanism. The subtype gives the framework a typed entry point, while the package behind it contains the real implementation.

## Why Oracle Object Types Are Used
For developers unfamiliar with Oracle object orientation, the use of object types here can look heavier than necessary. The benefit is mainly structural:

- `FSM_TYPE` defines which methods every concrete FSM must support
- a subtype guarantees that the implementation belongs to a concrete business object class
- static dependencies remain visible to the database, which is safer than resolving handlers through free-form dynamic PL/SQL

In short: object types are used here as a contract mechanism, not because the framework wants to be "fully object-oriented".

## Main Tables
The central metadata and runtime tables are:

- `FSM_CLASSES`: defines the business classes handled by the FSM runtime
- `FSM_STATUS`: defines the allowed states per class
- `FSM_EVENT`: defines the allowed events per class
- `FSM_TRANSITIONS`: defines which events are allowed in which state and which target states may result
- `FSM_OBJECTS`: stores the runtime state of each FSM instance
- `FSM_LOG`: stores the history and notifications emitted by the FSM

## Escalation Model
Each status may define two expected durations:

- `FST_WARN_INTERVAL`
- `FST_ALERT_INTERVAL`

The basis for the check is configured in `FST_ESCALATION_BASIS`:

- `STATUS`: compare against the last status change
- `EVENT`: compare against the last activity/event

The runtime uses two timestamps in `FSM_OBJECTS`:

- `FSM_LAST_CHANGE_DATE`: last relevant activity or event
- `FSM_STATUS_CHANGE_DATE`: last actual status change

This separation is required to distinguish a stalled process from a process that remains in the same state but continues to report activity.

Views such as `FSM_OBJECTS_V` derive a `STATUS_STATE` value:

- `OK`
- `WARN`
- `ALERT`

This makes it possible to detect stale objects even if repeated events do not change the status.

Typical examples are:

- a job that should leave `ORDERED` within a few minutes
- a long-running job in `RUNNING` that should keep sending progress updates

## Error and Retry Model
The runtime distinguishes between normal transitions, retries and technical failures.

- Invalid events are treated as errors.
- `SET_STATUS` contains a controlled fallback path to `FSM_ERROR`.
- If the regular error transition path cannot be executed, the runtime uses a hard fallback to force the object into `FSM_ERROR`.
- Retries persist the failed event and retry schedule in `FSM_OBJECTS`.

The current retry implementation is synchronous.

This is important for operational stability. A workflow framework is only useful if failures are visible and technically contained. The framework therefore prefers a clear error state over silent ambiguity.

## Visibility Model
Concrete FSM classes are tied to a SQL subtype via `FSM_CLASSES.FCL_TYPE_NAME`.

Visibility is derived from Oracle object-type privileges:

- a class is visible if its implementing type is visible in `ALL_TYPES`
- visibility can be delegated by granting `EXECUTE` on the concrete type
- the base class `FSM` remains globally visible

This means:

- a schema sees its own FSM classes
- another schema sees those classes only if it has `EXECUTE` on the implementing type
- unrelated FSM implementations remain hidden

This gives the framework a practical multi-schema model:

- the metadata remains central
- the business implementation stays local
- Oracle grants control which implementations are visible to which consumers

## Installation Rules
Concrete FSMs must be installed in this order:

1. create the concrete SQL subtype
2. register the class via `FSM_ADMIN.MERGE_CLASS`
3. create status, event and transition metadata
4. generate constant packages if needed
5. install the concrete event-handler package and business logic

`FSM_ADMIN.MERGE_CLASS` validates that `FCL_TYPE_NAME`:

- exists in `ALL_TYPES`
- is a subtype of `FSM_TYPE`
- is instantiable for concrete classes

This order is not incidental. The framework treats the SQL subtype as the technical truth of a concrete implementation, so the metadata registration step must not happen before the type exists.

## Recommended Design Rules
- Keep the FSM core generic and metadata-driven.
- Keep event-handler packages thin.
- Move non-trivial business decisions into `BL_*` packages.
- Let business logic decide the outcome, but let the FSM package perform the actual status change.
- Use generated constants from `FSM_FST` and `FSM_FEV` instead of hard-coded identifiers.

As complexity grows, this separation becomes increasingly valuable. Otherwise the event-handler package tends to become a mixture of metadata interpretation, persistence logic, technical error handling and business rules.
