---
name: plsql-refactoring
description: Refactor Oracle SQL and PL/SQL in FSM while preserving the generic runtime boundary, metadata model, object-type contracts, install order, grants, internationalized PIT metadata, Natural Docs documentation, and tests. Use for package or type changes, method moves, handler additions, dependency changes, error-path refactors, table and view changes, and other structural PL/SQL changes in this repository.
---

# PL/SQL Refactoring

Start with the relevant source and the focused maps in `.ai/`. Trace the current
path through type and package specifications, bodies, tables, views, grants,
synonyms, install scripts, PIT message and translation metadata, and tests before
changing it. Treat generated content below `Doc/` as derived documentation, not
as the source of truth.

## Refactor

1. Keep the `FSM` package and `FSM_TYPE` generic. Keep concrete FSM orchestration
   in concrete `FSM_*` packages and business decisions in local `BL_*` packages.
   The FSM schema must not depend on consuming application schemas.
2. Change package or type specifications and bodies together. Update every caller
   and affected test in the same change.
3. Preserve metadata-driven transitions, deterministic error fallback, retry
   behavior, logging, and escalation semantics unless the requested change
   explicitly revises their contract.
4. Preserve installation order and update tables, alignment scripts, views,
   initial data, grants, synonyms, messages, translations, and generated constant
   packages wherever the change requires them.
5. Keep affected `.ai` architecture and runtime maps current when dependencies,
   persistent data, runtime flow, or installation order change.

## Structure conditionals

Use `if` for simple decisions with one or two branches (`if` or `if ... else`).
Use `case` for decisions with more than two branches, where an `elsif` chain
would otherwise be required. Do not replace a simple binary decision with
`case`.

## Apply identifier casing

Write constant identifiers in uppercase. Write package names, SQL and PL/SQL
keywords, table names, and column names in lowercase. For a qualified constant,
write only the constant identifier in uppercase, for example
`msg.FSM_SQL_ERROR` or `dbms_aq.NO_WAIT`.

## Document methods

Document every added or materially changed public method in the package or type
specification and its implementation using the repository's Natural Docs format.
Include the method name, purpose, all parameters, return value when applicable,
and relevant error or side-effect behavior. Do not leave a new body method with
only the specification comment or a bare implementation.

Use `See: <PACKAGE.method>` in the body when the specification contains the
complete contract. Add body-specific details when the implementation has
important routing, persistence, transaction, or error behavior.

## Instrument safely

Use `pit.enter_*` and the matching `pit.leave_*` consistently.

The `msg_params(...)` list passed as `p_params` may contain scalar values only.
Never add a `msg_params` or `msg_args` object as the value of a `msg_param`,
because `pit.enter_*` does not accept these object types as parameter values.
Log a meaningful scalar summary such as count, identifier, or selected fields
instead.

Valid:

```sql
pit.enter_mandatory(
  p_params => msg_params(
                msg_param('item_count', p_items.count)));
```

Invalid:

```sql
pit.enter_mandatory(
  p_params => msg_params(
                msg_param('p_items', p_items),
                msg_param('p_message_args', p_message_args)));
```

## Validate

Run `git diff --check`. Execute focused tests or compile the affected schemas
when the task authorizes a live target. Review the final diff for undocumented
methods, stale specifications, missing install or migration steps, missing PIT
message or translation metadata, incompatible grants or synonyms, and stale
`.ai` maps.
