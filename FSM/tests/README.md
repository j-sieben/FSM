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

Run `install_scripts/install.sql` twice from the `FSM` directory before the
suite to verify an idempotent installation. Client grants and synonyms require a
separate saved connection for the consuming schema and can be checked there with:

```sh
sql -S -L -name "<client connection>" @FSM/tests/client_contract.sql B3M_UTILS
```

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
