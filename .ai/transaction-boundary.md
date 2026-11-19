# Event and transaction boundary

## Policy and lifetime

`FSM/core/scripts/ParameterGroup_FSM.sql` creates PIT boolean `FSM.AUTO_COMMIT`
(default TRUE) only when absent. Owner installation installs it before FSM can
initialize, including on repeat installation; existing values survive. Owner
uninstall removes the parameter group. PARAM/PARAM_ADMIN and normal PIT client
registration are prerequisites. The parameter uses NULL for its individual
modifiability flag and inherits the editable group policy. An explicit TRUE
violates PIT's PARAMETER_TAB constraint, which permits only FALSE or NULL.

FSM reads the effective value once into private `g_auto_commit` at package
initialization. It is not SERIALLY_REUSABLE: pool sessions retain this setting.
Changing PIT configuration requires a new session or package reset at a clean
transaction boundary. TRUE commits once at the successful outermost SET_STATUS
completion, after all synchronous children. FALSE leaves transaction and lock
duration to the caller. Internal commits also commit the caller's prior work.
There are no savepoints or FSM rollbacks.

Only the event/reason store is short-lived: the new `FSM_EVENT_CONTEXT` package
has `pragma serially_reusable` in spec and body. Its private stack is shared by
all instances within one server call, with full FSM identity on each frame, and
is discarded when that server call ends. It is not per object, per method call,
or per transaction. It contains no commits or PIT parameter lookup. ACCESSIBLE
BY (FSM) restricts direct use, and it receives no client grants or synonyms.

## Event admission and successful completion

LOCK_FSM is removed. FSM.RAISE_EVENT conditionally selects the FSM row FOR UPDATE
using its persisted event list (plus the generic ERROR event), then rereads common
state and rechecks ALLOWS_EVENT after any wait. Initial rejection locks no row;
post-wait rejection may retain a lock until the caller commits/rolls back.
ALLOWS_EVENT is optional advisory inspection of the in-memory object, without
locking or refreshing.

Admission pushes a frame and calls FSM_TYPE.refresh_state to reload subtype
payload under the same lock. Overrides only load: no writes, commits or mutation
of common identity/event fields. The sample request type reloads local domain
columns. Unsaved payload modifications are replaced; apply command inputs after
admission or keep them separately. The handler computes a target and calls public
SET_STATUS, which requires the current frame and validates the target transition.
No second refresh overwrites the handler's decision.

Automatic children enter through the instance's RAISE_EVENT and push their own
frames. Each successful SET_STATUS internally pops its frame and restores parent
event attributes. FSM's private completion method commits only if the stack is
then empty and g_auto_commit is TRUE. The helper reports emptiness but never
makes the commit decision. New-instance initialization uses a private
insert-capable frame; it does not complete twice after SET_STATUS returns.

**SET_STATUS is the successful transaction boundary.** Concrete handlers need no
FINISH_EVENT/ABORT_EVENT API; both have been removed from the FSM spec and callers.
Handlers must perform all transactional business work before their final
SET_STATUS. Work or exceptions afterward cannot undo an already committed status.
This differs deliberately from the previous implementation's handler-return
boundary. Existing wrapper completion calls must be removed when upgrading.

PERSIST is context-guarded and cannot recreate deleted existing rows. DROP_OBJECT
remains an explicit deletion API with normal DELETE locking and caller-owned
transaction control. A row lock does not identify an in-memory object; handlers
must keep using the refreshed instance.

## Retry and technical failures

Retry/error state is written in the main transaction, never autonomously.
Explicit business RETRY must run inside an admitted event **instead of after a
completed SET_STATUS**. It retains a parent frame during synchronous child
re-fires, then closes its own frame internally after a confirmed persisted retry
reservation or modeled error outcome. Pending scheduled retries may complete
without changing the status; terminal/no-op retry does not trigger a commit.
Counters, retry reservations and FSM_LOG rows roll back with application data.
Cross-delivery MQ attempt accounting belongs outside this rollback boundary.

Ambiguous error metadata, SQL failures, subtype-hook and log-persistence errors
propagate rather than becoming business FSM_ERROR. Failures caught inside FSM
(admission, initialization, SET_STATUS, RETRY) clear all helper frames/reasons and
report FSM_TECHNICAL_ERROR with captured stack/backtrace to PIT. PIT dispatches
output modules autonomously. Durable diagnosis requires an active persistent
output such as PIT_TABLE; it must not update locked FSM rows or require an
uncommitted FSM FK. Diagnostic failures must not replace the original exception.

A concrete handler can fail **before** entering SET_STATUS, outside FSM's catch
scope. Such an abandoned context expires at server-call completion, including
when the exception exits the work unit. If application code catches that error
inside the same server call, it must end that work unit and must not continue
processing or reuse the failed instance there. There is deliberately no exposed
context-cleanup API. A rollback alone does not clear call-local state. Diagnostic
logging for errors outside FSM remains the concrete application's normal PIT
exception handling responsibility. A later server call starts with an empty
helper even though FSM's cached commit setting remains alive.

Oracle forbids access to SERIALLY_REUSABLE packages from triggers and from PL/SQL
invoked by SQL statements. Use procedural PL/SQL for FSM events, initialization
and logging; do not invoke these from SQL object constructors/functions or
triggers. The helper follows Oracle's [server-call lifetime and restrictions](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/serially_reusable-packages.html).

## Installation, scope and tests

The shared owner install creates the helper spec before FSM's spec and its body
before FSM's body. Repeat installation replaces it; owner uninstall drops it.
Client registration and deregistration do not publish it. FSM_TYPE attributes and
constructors are unchanged. Dependent subtypes still need the refresh hook for
persisted payload; the sample and test handlers need no completion protocol.

The autonomous monitor remains separate and unchanged. It can contend with FSM
rows; do not call it inside a transaction holding those rows. Schedule separately.
Its independently committed state/logs are outside MQ rollback atomicity.

`tests/static/transaction_contract.py` checks restricted helper access, SR in both
units, no helper transaction/configuration policy, owner-only lifecycle, absence
of exposed completion calls, and nested-before-pop / empty-stack-before-commit
ordering. `tests/transactions/run.sql` checks TRUE/FALSE, cached PIT policy,
parameter reinstallation, refresh, rollback, nested failures within SET_STATUS,
retry/error persistence and separate-server-call cleanup. The new
`call_boundary.sql` deliberately abandons an admitted context and verifies that
the next server call cannot use it and can commit its own new root event.

Two-session concurrency scripts check actual waiting and post-wait decisions.
The existing owner and utPLSQL regressions remain relevant. No live target was
designated: Oracle compilation, ACCESSIBLE BY runtime checks, call-boundary
behavior and regression execution remain pending. Passing source checks are not
an Oracle compile result. See FSM/tests/README.md for disposable-target execution.
