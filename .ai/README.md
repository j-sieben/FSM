# AI architecture workspace

This directory contains compact, durable maps for understanding and maintaining the FSM project. The maps are curated from source files and should describe architecture rather than repeat generated documentation.

## Contents

- [architecture-map.md](architecture-map.md): components, responsibilities, dependencies, and source-of-truth locations
- [runtime-flow.md](runtime-flow.md): event processing, persistence, retry, and failure paths

## Maintenance rules

1. Update a map when a code change alters an architectural relationship or runtime flow.
2. Link claims to source paths so they can be checked quickly.
3. Prefer small Mermaid diagrams and concise prose over generated inventories.
4. Do not treat `Doc/` as source of truth; it contains generated HTML and JavaScript alongside authored Markdown.
5. Before modifying PL/SQL (`*.sql`, `*.pks`, `*.pkb`, `*.tps`, `*.tpb`, `*.tbl`, `*.vw`, `*.seq`), load and follow the **PL/SQL refactoring skill**. If it is unavailable, stop without editing PL/SQL and report the missing prerequisite.

The operative PL/SQL instruction is also recorded in the repository-root `AGENTS.md` so it is applied before future edits.
