# Event and transaction boundary

## Policy

`FSM/core/scripts/ParameterGroup_FSM.sql` creates PIT boolean `FSM.AUTO_COMMIT`
(default TRUE) only when absent. The common owner install invokes it before FSM
can be initialized, including on repeat installation; configured default/local
values survive. Owner uninstall removes the parameter group. `PARAM`,
`PARAM_ADMIN` and their existing PIT client registration are prerequisites.

The initialization section of `FSM/core/packages/fsm.pkb` reads the effective
PIT value once into private `g_auto_commit`. There is no setter or per-call
parameter. Changing PIT configuration does not change an already instantiated
package. Use a fresh session or reset packages at a clean transaction boundary;
connection pools must not assume rollback resets package variables.

TRUE commits once, at successful completion of the outermost event/initialization
chain. This commits all prior work in that session too. FALSE performs no FSM
commit or rollback: the caller owns the transaction and lock duration. Rejection
and technical errors never commit in either mode. There are no savepoints.

## Context protocol and locking

`LOCK_FSM` has been removed from the public package and body. `FSM.RAISE_EVENT`
conditionally selects the FSM row FOR UPDATE using its persisted allowed-event
list (plus the existing generic ERROR event). Initial rejection locks no row;
NULL is rejected. After any wait, a separate SELECT reloads common state and
ALLOWS_EVENT rechecks it. Rejection at that point can retain the row lock; only
the caller's commit/rollback releases it. ALLOWS_EVENT remains an optional,
non-locking, in-memory advisory query, not an admission guarantee.

Admission pushes a nested event frame and calls the new `FSM_TYPE.refresh_state`
hook to reload subtype payload under the same lock. Overrides must only load,
not write, commit or alter common identity/event state. The sample request type
reloads its domain columns directly from its local table. Common FSM identity,
status, validity, event list and automatic flag are refreshed by FSM itself.
Unsaved local payload modifications are intentionally replaced: pass command
inputs separately or apply them after admission.

The generic RAISE_EVENT returns to the concrete handler, which calculates a
potentially data-dependent target and calls the public SET_STATUS. This method
requires the top context for that FSM ID/class/subclass; the target must be in
the active transition's list (or the generic ERROR target). It does not reload or
commit. PERSIST likewise requires context and cannot recreate a missing existing
instance. Initialization has a private insert-capable frame and rejects reuse of
an existing identity. Object attributes/constructors are unchanged; REFRESH_STATE
is an added virtual method.

Every concrete entry must call FINISH_EVENT after handler/business retry work,
and ABORT_EVENT plus bare RAISE in its exception handler. FINISH_EVENT requires a
status or retry confirmation. Only the outermost finish optionally commits;
nested finishes restore the parent's transient event attributes. Contexts are
closed even when external transaction control retains the physical lock. They
are not evidence of lock ownership after a call. No SQL transaction is inferred
from persistent package state. A different in-memory object with the same ID is
not distinguishable by Oracle row locks; concrete code must continue using the
same refreshed object throughout its handler.

## Retry and diagnosis

PERSIST_RETRY and FORCE_ERROR_STATUS are ordinary writes in the admitted event
transaction. Standalone RETRY is rejected. Retry reservations, counters and FSM
logs roll back with the business data. A cross-delivery MQ attempt counter must
be maintained separately by the delivery infrastructure.

Explicit business failure can schedule/re-fire a retry, execute the class/subclass
error transition, or force the modeled ERROR state if no error route exists.
Ambiguous error metadata, SQL errors, hook failures and logging errors propagate;
they are not converted to business ERROR by SET_STATUS. Error-route lookup uses
the full class/subclass and active flag; its NO_DATA_FOUND handling is confined
to that lookup. Retry persists its permitted error event list before nested
admission. Synchronous retry sleeps hold the parent lock until completion.

ABORT_EVENT clears all event/reason frames and passes identity, captured error
stack and backtrace to PIT. The inspected sibling PIT implementation dispatches
output modules autonomously (`PIT_INTERNAL.raise_event`); no new FSM diagnostic
table, grants or autonomous state writers are introduced. Durable visibility
requires an installed, active persistent PIT output (e.g. PIT_TABLE). It must not
write locked FSM rows or depend on an uncommitted FSM FK. Check its output after
rolling back a fault-injected event. Logging infrastructure failures cannot
replace the original exception: ABORT_EVENT preserves the caller's bare RAISE.
Nested catches may report the same exception at more than one boundary.

Rollback does not restore SQL object attributes or package variables. After a
technical error, discard/reload the instance and roll back the failed unit before
continuing. Do not catch errors and commit its partially executed business work.

## Migration and scope

The sample package and utPLSQL handler use the completion protocol. External
concrete handlers must be migrated too; old handlers which only call the generic
RAISE_EVENT and SET_STATUS leave a context open and no longer auto-commit.
Recompile dependent subtypes/packages after installing the updated base type.
Audit hooks and concrete BL packages for independent commits/autonomous writes.
The sample handler/BL paths contain no such commits.

DROP_OBJECT remains an explicit deletion API; DELETE obtains its normal row lock
and the caller owns its transaction. No public standalone lock replaces LOCK_FSM.
The autonomous monitor is a separate existing transaction contract and is not
changed here. It writes FSM_OBJECTS/FSM_LOG, can contend with events, and must not
be invoked synchronously inside a transaction holding those rows. Schedule it
from a separate session; its state/logs are outside MQ rollback atomicity.
Metadata administration and direct application-table editing are separate APIs.

## Verification

`tests/static/transaction_contract.py` checks the single gated commit, absence of
savepoints/autonomous state writes, guarded mutation paths, admission/refresh
ordering and concrete completion/abort wiring. It is not an Oracle compiler.
`tests/transactions/run.sql` tests TRUE/FALSE in fresh package instances,
repeat parameter installation, cached policy, rollback/visibility via an
independent autonomous reader, stale state refresh, direct-write rejection,
original error propagation, context cleanup, nested automatic chains and retry
under the parent's lock. Use a disposable, quiet owner; it changes realm-local
PIT configuration and restores it on normal completion. On failure, preserve the
original settings and restore/clean the disposable fixture manually.

`tests/transactions/concurrent_a.sql` and `concurrent_b.sql` exercise actual lock
waits and post-wait refresh/rejection in two sessions. Existing utPLSQL tests now
use events for unchanged-state changes and expect direct writes/technical
fallback errors to be rejected. See `FSM/tests/README.md` for execution details.
No live target was designated: Oracle compilation and database regressions are
pending, not represented by the passing source checks.
