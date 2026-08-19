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
