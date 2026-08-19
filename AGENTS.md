# Repository instructions

## PL/SQL changes

- Before changing any PL/SQL artifact, load and follow the local **PL/SQL refactoring skill** (`$plsql-refactoring`) in `.agents/skills/plsql-refactoring/`.
- PL/SQL artifacts include at least `*.sql`, `*.pks`, `*.pkb`, `*.tps`, `*.tpb`, `*.tbl`, `*.vw`, and `*.seq`.
- If that skill is unavailable, do not modify PL/SQL. Tell the user that the required skill is missing and ask them to install or provide it.
- This requirement also applies to generated PL/SQL and to PL/SQL embedded in installation or migration scripts.

## Architecture documentation

- Keep durable AI-oriented architecture notes and maps in `.ai/`.
- Update the relevant `.ai/` map when a change alters components, dependencies, persistent data, runtime flow, or installation order.
- Treat generated content below `Doc/` as a derived view, not as the architectural source of truth.
