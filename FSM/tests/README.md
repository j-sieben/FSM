# FSM database tests

Run the complete suite from the repository root with SQLcl:

```sh
sql -S -L -name "B3M_UTILS Rack" @FSM/tests/run_all.sql
```

The suite expects an installed FSM owner schema with PIT available. Tests use
fixed dates, create their own temporary metadata and SQL subtypes, and clean up
after themselves. Any unexpected SQL or operating-system error terminates SQLcl
with a failing exit code.

`installation_contract.sql` is read-only. The remaining scripts may also be run
individually while developing a focused change. Generated event and status
constant packages are covered by the separate repeated-installation check,
because regenerating them invalidates dependent stateful packages in the current
database session.

Run the supported owner installer twice before the suite, or supply trusted
version/commit arguments to `install_scripts/install.sql` from the `FSM`
directory (see the root README). Do not omit these arguments on direct SQL runs.
Repeated installation verifies idempotency. Client grants and synonyms require a
separate saved connection for the consuming schema and can be checked there with:

```sh
sql -S -L -name "<client connection>" @FSM/tests/client_contract.sql B3M_UTILS
```

## Installation versioning

```sh
python3 FSM/tests/static/versioning.py
```

This creates temporary Git repositories and a fake SQL*Plus executable. It checks
whole-repository counting, major/minor changes, dirty/staged/untracked and shallow
checkout rejection, invalid version rejection, offline ZIP metadata and stale
metadata precedence. It exercises the Unix starter from another directory with
spaces in the source path and verifies SQL*Plus argument forwarding and failure
propagation. With `pwsh` available it also tests the PowerShell helper against the
same cases; otherwise those cases are skipped. Offline installation is tested
with a PATH containing neither Python nor Git. Python runs only this optional
test suite, not installation or export. No database is contacted. Windows batch
execution and Windows PowerShell 5.1 require a separate Windows host; this suite
tests PowerShell Core on the current host when available.

`installation_contract.sql` exercises the SQL version API; `client_contract.sql`
also queries it through existing client grants and synonyms. The installation's
own final check compares both returned values to the supplied identity. Run a
real owner installation twice and the owner/client contracts on a designated
test database to verify Oracle compilation and substitution end to end.

## utPLSQL runtime suite

The `utplsql` directory contains end-to-end tests for the generic FSM runtime.
It installs a temporary concrete subtype and verifies initialization, persisted
state, lifecycle hook order, automatic event chains and terminal finalization.

```sh
sql -S -L -name "B3M_UTILS Rack" @FSM/tests/utplsql/install.sql
sql -S -L -name "B3M_UTILS Rack" @FSM/tests/utplsql/run.sql
sql -S -L -name "B3M_UTILS Rack" @FSM/tests/utplsql/uninstall.sql
```

## Technical view layer

Without a database, run `python3 FSM/tests/static/technical_views.py` from the
repository root. This verifies every core table's explicit complete projection,
comments, installation placement and client lifecycle wiring.

`technical_view_contract.sql` runs in the owner suite. It compares datatypes,
dependencies, row counts and complete PK-ordered XML values under AMERICAN and
GERMAN NLS languages, including stored text and collection arguments. Use a quiet
test database with bounded fixture data; it materializes the XML and compares
separate queries. Run the existing runtime, monitor, log and admin regressions
through `run_all.sql`. The final invalid-object checks include all ten `_tv`s.

For a designated disposable owner/client test environment:

1. Run the owner installation twice, then `run_all.sql` (fresh and upgraded
   installations should each be covered). Keep a before/after invalid-object
   inventory for the whole target schema in addition to the suite's FSM checks.
2. Run `install-client` twice, then `client_contract.sql <owner>` as the client.
   It verifies all ten direct delegable READ grants, exact synonyms and queries.
3. As the client, create a temporary local view with explicit columns, e.g.
   `create view fsm_tv_delegation_test as select fsm_id from fsm_objects_tv`.
   Grant READ on that local view to a designated test reader, query as that
   reader, then drop the temporary view. This verifies onward delegation in the
   real target privilege configuration; do not substitute table grants.
4. Run `uninstall-client` twice, then `technical_client_removed.sql <owner>` as
   the client. Reregister and rerun the client contract to verify recovery.
5. Only on the disposable owner, uninstall and assert that no objects from the
   ten-name technical view inventory remain; reinstall and rerun the suite.

The `_tv` source and single-table dependency checks prove independence from PIT
translation/language APIs. The NLS test additionally exercises Oracle session
language switching; it does not assume an undocumented PIT language setter.
No live target is selected automatically from saved connections or old logs.

## Event transaction ownership and concurrency

Run the source safety check without a database:

```sh
python3 FSM/tests/static/transaction_contract.py
```

After owner installation, run the separate transaction suite in a **disposable,
quiet FSM owner**, not in a live application session:

```sh
sql -S -L -name "<designated disposable owner>" @FSM/tests/transactions/run.sql
```

It temporarily changes the realm-local PIT `FSM.AUTO_COMMIT` parameter, resets
package state between modes, creates class FTX, a test type, package and trace
table, and cleans up/restores the original local setting on success. If a check
fails, the runner stops: restore the original PIT setting and remove the fixture
with `transactions/uninstall.sql` before reusing the test owner. The suite is
separate from `run_all.sql` because package reset and parameter changes must not
occur inside an application transaction or the utPLSQL runner.

Checks include parameter value preservation on repeated installation, cached
package policy, initialization/event visibility from an autonomous read-only
probe, rollback, stale-object refresh, subtype reload hook invocation, rejection
without caller commit, direct-write protection after success/failure, original
status-hook error propagation, nested automatic failure without intermediate commits,
and retry while the parent already holds the FSM lock. The probe's rollback is
confined to its independent test transaction; production FSM contains no rollback
or savepoint.

For real contention, install the fixture with `transactions/install.sql`, then
run `transactions/concurrent_a.sql` in session A. While it sleeps holding the row
lock, pass its printed ID to session B:

```sql
@FSM/tests/transactions/concurrent_b.sql <ID> ADVANCE
```

B must wait, refresh from START to MIDDLE, and choose DONE. Repeat A with a new ID
and run B with `START_ONLY`; it must reject the now-invalid event. Inspect elapsed
time to confirm overlap. Also test a caller rollback in A instead of commit:
B must proceed from START. Do not run other workloads against the fixture. These
scripts leave local AUTO_COMMIT FALSE; restore the prior setting afterward and
remove FTX with `transactions/uninstall.sql`.

Verify durable diagnostics on the designated target: enable a persistent PIT
output module (e.g. PIT_TABLE), run the injected `-20080` failures, roll back the
business transaction and inspect PIT's log for `FSM_TECHNICAL_ERROR`, FSM ID, original
stack/backtrace. No log should require writing a locked FSM row. Repeat with
failure in subtype refresh/persistence hooks and a failed error-route lookup.
PIT modules/configuration are external; the source check does not prove that a
particular target has durable diagnostics enabled.

Run owner installation twice, `run_all.sql`, and the updated utPLSQL runtime
suite. Compare invalid objects before/after, including external dependent SQL
subtypes. Concrete handlers no longer call finish_event/abort_event: SET_STATUS
owns successful completion. Implement refresh_state for persisted subtype payload,
and perform all transactional work before the final SET_STATUS. See [.ai/transaction-boundary.md](../../.ai/transaction-boundary.md).
No live compilation or regression run is implied by the source checks.

The internal FSM_EVENT_CONTEXT package is SERIALLY_REUSABLE and accessible only
by FSM. It has no client grants/synonyms and no commit policy. The transaction
runner additionally executes call_boundary.sql as separate server calls: a
context abandoned before SET_STATUS must expire, without resetting normal FSM
package state. Direct anonymous access to the helper must fail with PLS-00904.
Fault injection now happens in AFTER_TRANSITION inside SET_STATUS, not after its
successful return, since that return is the new completion/commit boundary.
Errors caught in concrete handlers before SET_STATUS require ending the server
call; rollback alone does not clear an abandoned context in that same call.
Oracle prohibits SR access from SQL-invoked PL/SQL and triggers, so run the suite
and FSM event entry procedurally, not through SELECT or trigger execution.
