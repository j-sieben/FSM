# Technical read contracts

## Inventory and boundary

The complete core inventory in `FSM/core/tables/*.tbl` contains ten tables. Each
is published through a same-name `_tv` in `FSM/core/views/`, with all stored
columns projected explicitly and unchanged. There are no expressions, filters,
joins, translations, session functions, or dependencies on enriched `_v` views.
These contracts expose inactive, terminal and all-class rows too; they are not
an authorization or class-visibility filter. Readers need an explicit view grant.

| Contract | Complete primary key | Notable retained attributes |
|---|---|---|
| `FSM_CLASSES_TV` | `FCL_ID` | PTI reference, implementing type, active flag |
| `FSM_SUB_CLASSES_TV` | `FSC_ID, FSC_FCL_ID` | PTI reference, active flag |
| `FSM_STATUS_GROUPS_TV` | `FSG_ID, FSG_FCL_ID` | PTI reference, icon/CSS, active flag |
| `FSM_STATUS_SEVERITIES_TV` | `FSS_ID, FSS_FCL_ID` | PTI reference, HTML, icon |
| `FSM_MONITOR_STATUS_TV` | `FMS_ID` | PTI/group reference, sort order, active flag |
| `FSM_EVENTS_TV` | `FEV_ID, FEV_FCL_ID` | message/PTI references, user/button flags, confirmation text, icon |
| `FSM_STATUS_TV` | `FST_ID, FST_FCL_ID` | group/message/PTI references, retries, schedule/time, escalation intervals/basis, icons/CSS, initial/terminal/active flags |
| `FSM_TRANSITIONS_TV` | `FTR_FST_ID, FTR_FEV_ID, FTR_FCL_ID, FTR_FSC_ID` | target list, role, automatic/error routing, reason message, active flag |
| `FSM_OBJECTS_TV` | `FSM_ID` | class/subclass/status/event, permitted events, retry schedule/validity, activity/status/monitor timestamps and persisted monitor code |
| `FSM_LOG_TV` | `FSL_ID` | object/class/subclass, status/event/previous status, timestamps/user/session, stored message text, severity, message and reason keys/arguments |

All ten existing `FSM_*_V` contracts remain unchanged. The remaining three core
views (`BL_FSM_ACTIVE_STATUS_EVENT`, `BL_FSM_EDGES`, `BL_FSM_NEXT_COMMANDS`) are
filtered/expanded business projections, not additional persistent objects. Their
underlying data is fully covered above; no technical duplicates are needed.
Sequences, packages and SQL object types are execution contracts rather than
additional read models. Tables/views below `FSM/sample_app/` belong to the demo
application and are not published FSM core contracts. Historical names mentioned
only in cleanup/uninstall scripts are not current installed read contracts.
There are no core materialized views to publish or grant.

Stored user text (`FEV_CONFIRM_MESSAGE`, `FSL_MSG_TEXT`) and `MSG_ARGS_CHAR`
payloads are preserved. Language neutrality means no lookup translation during
reading; it does not promise that stored text was originally written in a
language-neutral form. Foreign keys to PIT do not make reading these views
dependent on PIT translation views. Datatypes of log arguments still require the
existing PIT SQL type installation.

## PIT severity prerequisite

`FSM_STATUS_V.FST_SEVERITY` is `PIT_MESSAGE_V.PMS_PSE_ID`, joined using
`FST_MSG_ID = PMS_NAME` and `FST_FCL_ID = PMS_PMG_NAME`. `FSM_STATUS` itself has
no severity column. Consequently `FSM_STATUS_TV` publishes the message/class
keys but no invented `FST_SEVERITY`. `FSM_STATUS_SEVERITIES_TV` contains the
FSM GUI severity metadata; it does not supply the missing status-to-message
severity relationship. `FSM_LOG_TV.FSL_SEVERITY` is an independently stored fact.

A future PIT-owned technical message view (proposed name `PIT_MESSAGE_TV`, not
an asserted existing API) must expose at least `PMS_NAME`, `PMS_PMG_NAME` and
`PMS_PSE_ID`, with documented stable key/cardinality matching PIT's real message
model, independent of translation availability and session language. It must
preserve messages without translations and provide direct view READ privileges
with the onward rights required for client-owned mapping views, plus PIT client
synonyms and lifecycle support. PIT must confirm whether message names are global
or class/group scoped; FSM consumers must retain the class/group join either way.
No PIT source is present in this subrepository, so implementation and validation
of this API remain an explicit external prerequisite. The existing `_v` severity
supply remains intact. This addition does not depend on that future API.

## Installation and client lifecycle

`FSM/core/install.sql` installs all ten technical views after table alignment
and before enriched views. Each depends only on its base table, so ordering
among the technical views is immaterial. `create or replace view` supports both
fresh installation and the existing repeated-install/upgrade path; no new table
alignment is needed. Oracle preserves existing view grants on replacement.

Both supported launchers (`FSM/fsm.sh`, `FSM/fsm.bat`) call
`install_scripts/install.sql` -> `core/install.sql`. Direct SQL installation uses
the same scripts. Legacy shell/batch wrappers under `install_scripts/legacy/`
forward to these launchers; there is no separate legacy SQL implementation.
Sample installation consumes the core and does not install another copy.

For each `_tv`, `core/grant_client_access.sql` adds only `READ ... WITH GRANT
OPTION`, using the existing helper and conventions. `core/register_client.sql`
creates the same-name private synonym pointing to the FSM owner. This supports
client-owned views and onward grants without new table or materialized-view
grants. Existing grants, including the historical table REFERENCES grant, are
untouched. Existing clients require rerunning `install-client` after the owner
upgrade: owner installation does not enumerate or automatically register clients.
Grant helpers retain their existing error-reporting behavior; the client contract
test must be used to detect missing grants.

`core/revoke_client_access.sql` revokes the ten view grants;
`core/uninstall_client.sql` removes their synonyms. `core/uninstall.sql` also
includes all ten owner views. Repeated registration replaces synonyms and
repeated deregistration tolerates absent grants/synonyms by existing convention.
Removing a client may invalidate its own dependent views, as with existing read
contracts. The technical view addition itself leaves runtime, administration and consuming
applications unchanged. Subsequent runtime transaction changes are documented in
[transaction-boundary.md](transaction-boundary.md). Application mapping views and page 29 migration are separate.

## Validation and target status

`FSM/tests/static/technical_views.py` checks the complete core inventory,
explicit exact projections, column comments, install placement, grants,
synonyms, revoke and both uninstall inventories. This is also a structural proof
that translation/session language cannot affect technical row membership.
`FSM/tests/technical_view_contract.sql` is part of `run_all.sql`: it checks valid
views, full SQL datatype parity, exact base-table dependency (plus stored SQL payload types), row counts and
PK-ordered complete values (including CLOB and collection payloads) under
AMERICAN and GERMAN NLS languages. The prior NLS language is restored. Run on a
quiet test target because base/view comparisons are separate statements; XML
comparison materializes the data and is intended for bounded test data.
NLS switching does not exercise a PIT-specific language setter; independence
from PIT language follows from the absence of PIT/function/view dependencies
and the exact projection source check.

No live environment was designated for this change. Oracle compilation,
repeated installation, client queries/delegation/deregistration and the existing
runtime/admin/monitor regressions must be run on a designated target using the
procedure in `FSM/tests/README.md`; they are not claimed as locally executed.
