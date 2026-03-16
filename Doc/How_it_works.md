# How It Works
This document explains the runtime flow of the project using the sample application as a reference.

It is aimed at readers who understand PL/SQL, but may not be deeply familiar with finite-state machines or Oracle object inheritance.

## Before Looking at the Mechanics
A finite-state machine always answers three questions:

- Where is the object right now
- Which events are allowed next
- Which status may result from such an event

This project answers those questions through a combination of metadata and code:

- metadata defines the legal process graph
- code implements the business action and, where necessary, the decision logic

That split is the central design principle of this repository.

## 1. Create a Concrete FSM Type
Every concrete implementation starts with a SQL subtype of `FSM_TYPE`.

It is not required that the concrete subtype adds new attributes of its own.

The minimal requirement is that the implementation can map the internal `FSM_ID` to the identifier of the underlying business object. That mapping is what allows the FSM runtime to re-create the concrete instance and reconnect it to the business data.

So there are two valid implementation styles:

- a subtype with additional business attributes cached on the object itself
- a subtype without additional attributes, where `FSM_ID` is used to look up the business object through local persistence logic

Example:

```sql
create or replace type fsm_req_type under fsm_type(
  req_rtp_id varchar2(50 char),
  req_rre_id varchar2(50 char),
  req_text varchar2(1000 char),
  constructor function fsm_req_type(
    self in out nocopy fsm_req_type,
    p_req_id in number default null,
    p_req_rtp_id in varchar2,
    p_req_rre_id in varchar2,
    p_req_text in varchar2)
    return self as result,
  constructor function fsm_req_type(
    self in out nocopy fsm_req_type,
    p_fsm_id in number)
    return self as result,
  overriding member function raise_event(
    p_fev_id in varchar2)
    return number,
  overriding member function set_status(
    p_fst_id in varchar2)
    return number
);
```

The subtype adds business-specific attributes. The generic runtime attributes remain in `FSM_TYPE`.

These additional attributes are optional. They are useful if the object should temporarily carry business data in memory during event processing, but they are not required by the framework itself.

The type body should stay thin. In this project, type methods delegate to a package such as `FSM_REQ`.

This is an important design choice. Oracle type bodies are comparatively limited. Packages offer better support for helper methods, encapsulation and larger procedural implementations. The object type exists mainly to provide inheritance and a stable method contract.

## 2. Register the Class
After creating the SQL subtype, register the class in `FSM_CLASSES` through `FSM_ADMIN.MERGE_CLASS`.

Important fields:

- `FCL_ID`: business class identifier
- `FCL_TYPE_NAME`: implementing SQL subtype

`FSM_ADMIN` validates that `FCL_TYPE_NAME`:

- exists in `ALL_TYPES`
- is a subtype of `FSM_TYPE`
- is instantiable for concrete classes

The install order matters. The SQL subtype must exist before `MERGE_CLASS` is called.

Conceptually:

- the SQL type says "this implementation exists"
- the metadata says "this implementation participates in the FSM framework"

## 3. Store Runtime Data
Business attributes are stored in the local application tables. Generic FSM runtime data is stored in `FSM_OBJECTS`.

Typical setup:

- local application table for the business object
- `FSM_OBJECTS` for generic FSM data
- local view joining both

`FSM_OBJECTS` stores:

- `FSM_ID`
- class and current status
- allowed next events
- retry state

## 4. Define Statuses, Events and Transitions
The process model is defined by metadata:

- `FSM_STATUS`
- `FSM_EVENT`
- `FSM_TRANSITIONS`

Transitions describe:

- which event is allowed in a given status
- which target statuses are allowed
- whether an event is raised automatically
- whether it is an error callback transition

The FSM engine uses this metadata to:

- derive the allowed event list for the current status
- validate incoming events
- determine whether an automatic follow-up event has to be raised

This keeps the legal process path data-driven. The framework does not hard-code the graph of allowed movements in the package logic.

## 5. Generate Constant Packages
`FSM_ADMIN` can generate:

- `FSM_FST` for statuses
- `FSM_FEV` for events

Use these constants instead of hard-coded string literals. That keeps the implementation stable and avoids typo-based runtime errors.

In practice this is more important than it sounds. A large part of FSM-related defects are simple identifier mismatches. Generated constants reduce that risk considerably.

## 6. Implement Event Handling
The concrete package, for example `FSM_REQ`, receives the incoming event and dispatches it to a handler.

A typical event handler does two things:

- call the local business logic
- decide which target status should be reached

Those two duties should not be confused.

The business logic answers a domain question such as:

- was the request approved
- is the external system reachable
- is the progress already complete

The FSM package then translates that result into the next process state.

Simple case:

```sql
function raise_default(
  p_req in out nocopy fsm_req_type,
  p_fev_id in varchar2)
  return binary_integer
as
begin
  p_req.fsm_validity := fsm.c_ok;
  return p_req.set_status(
           fsm.get_next_status(
             p_fsm => p_req,
             p_fev_id => p_fev_id));
end raise_default;
```

Complex case:

- the handler calls a `BL_*` package
- the business logic returns a decision or target status
- the handler calls `SET_STATUS` with the outcome

This keeps the FSM package responsible for orchestration, while business packages remain focused on domain rules.

That separation becomes especially useful when several different events depend on the same business decision logic.

## 7. Runtime Flow
At runtime the flow is:

1. load or create a concrete FSM object
2. call `RAISE_EVENT`
3. validate that the event is allowed
4. execute local business logic
5. set `FSM_VALIDITY`
6. call `SET_STATUS`
7. persist runtime data
8. log the movement
9. optionally auto-raise the next event

The important point is that the FSM does not replace business logic. It wraps business logic with a controlled transition mechanism.

If the event does not lead to a status change, persistence still updates the activity timestamp. This is required for event-based escalation checks.

That is the mechanism that supports progress-style events in long-running states.

## 8. Escalation Checks
Statuses may define:

- `FST_WARN_INTERVAL`
- `FST_ALERT_INTERVAL`
- `FST_ESCALATION_BASIS`

`FST_ESCALATION_BASIS` decides which timestamp is compared with `SYSDATE`:

- `STATUS`: use the last status change
- `EVENT`: use the last activity/event

The required timestamps are stored in `FSM_OBJECTS`:

- `FSM_LAST_CHANGE_DATE`: updated whenever a relevant event is persisted
- `FSM_STATUS_CHANGE_DATE`: updated only when the status really changes

Without this distinction, the framework cannot tell the difference between:

- "the process is still active in the same state"
- "the process is stuck in the same state"

`FSM_OBJECTS_V` derives `STATUS_STATE`:

- `OK`
- `WARN`
- `ALERT`

This supports both a waiting state and a heartbeat or progress state.

So a state can now carry an operational expectation, not just a semantic meaning.

## 9. Error Handling
The engine is defensive by design.

- Invalid events are treated as errors.
- If a status change fails, `SET_STATUS` tries to move the object into `FSM_ERROR`.
- If the normal error transition path also fails, the runtime uses a hard fallback and forces the object into `FSM_ERROR`.

This ensures that technical failures do not leave an object in an undefined state.

In other words: the framework prefers a visible technical error over a silently inconsistent workflow position.

## 10. Retry Handling
Retries are metadata-driven.

If a transition fails and retries are configured for the status, the runtime persists:

- the failed event
- the retry schedule
- the retry state

The current implementation retries synchronously. The persisted attributes are already structured so that a later asynchronous dispatcher job can pick them up.

This is a pragmatic intermediate state. The metadata and persistence model already support a cleaner asynchronous retry mechanism, but the current implementation keeps the execution model simple.

## 11. Visibility of Classes
Class visibility is based on the implementing type, not on an owner column in the metadata.

A class is visible if:

- it is the base class `FSM`, or
- its `FCL_TYPE_NAME` is visible in `ALL_TYPES`

This means a concrete class becomes visible to another schema if the owner grants `EXECUTE` on the implementing SQL type.

That gives a practical visibility model:

- a schema sees its own FSM implementations
- an application schema sees another schema's FSM implementation only if the type was granted explicitly

This is preferable to introducing a second custom visibility model in metadata. Oracle privileges already express exactly the sharing semantics the framework needs.

## 12. Recommended Structure
For maintainability, keep the layers separated:

- `FSM` package: generic runtime behavior
- `FSM_<CLASS>` package: persistence and event orchestration
- `BL_<CLASS>` package: business decisions

Use the FSM package to control state, not to hold all domain logic.

If the event-handler package grows into a full business layer, the benefits of the FSM abstraction start to erode.

## 13. Sample Application
The sample application demonstrates this pattern with `FSM_REQ_TYPE`.

It shows:

- how a concrete subtype is created
- how the class is registered
- how statuses, events and transitions are installed
- how event handlers call business logic and set the resulting status
