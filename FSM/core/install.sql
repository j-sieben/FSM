prompt fsm core installation

define table_dir=&CORE_DIR.tables/
define type_dir=&CORE_DIR.types/
define view_dir=&CORE_DIR.views/
define sequence_dir=&CORE_DIR.sequences/
define pkg_dir=&CORE_DIR.packages/
define script_dir=&CORE_DIR.scripts/

prompt - cleaning up installation
@&CORE_DIR.clean_up.sql

prompt - creating default messages
@&CORE_DIR.messages/&DEFAULT_LANGUAGE./create_messages.sql
@&CORE_DIR.messages/&DEFAULT_LANGUAGE./TranslatableItemsGroup_FSM.sql

prompt - create type specifications
prompt . - type fsm_type
@&type_dir.fsm_type.tps

prompt - create tables
prompt . - table FSM_CLASSES
@&table_dir.fsm_classes.tbl

prompt . - table FSM_STATUS_GROUPS
@&table_dir.fsm_status_groups.tbl

prompt . - table FSM_EVENTS
@&table_dir.fsm_events.tbl

prompt . - table FSM_STATUS
@&table_dir.fsm_status.tbl

prompt . - table FSM_TRANSITIONS
@&table_dir.fsm_transitions.tbl

prompt . - table FSM_OBJECTS
@&table_dir.fsm_objects.tbl

prompt . - table FSM_LOG
@&table_dir.fsm_log.tbl

prompt . - table FSM_STATUS_SEVERITIES
@&table_dir.fsm_status_severities.tbl


prompt - create views
prompt . - view FSM_CLASSES_V
@&view_dir.fsm_classes_v.vw

prompt . - view FSM_STATUS_GROUPS_V
@&view_dir.fsm_status_groups_v.vw

prompt . - view FSM_EVENTS_V
@&view_dir.fsm_events_v.vw

prompt . - view FSM_STATUS_V
@&view_dir.fsm_status_v.vw

prompt . - view FSM_TRANSITIONS_V
@&view_dir.fsm_transitions_v.vw

prompt . - view FSM_OBJECTS_V
@&view_dir.fsm_objects_v.vw

-- BL-Views
prompt . - view FSM_FSL_LOG_V
@&view_dir.fsm_fsl_log_v.vw

prompt . - view BL_FSM_NEXT_COMMANDS
@&view_dir.bl_fsm_next_commands.vw

prompt . - view BL_FSM_HIERARCHY
@&view_dir.bl_fsm_hierarchy.vw

prompt . - view BL_FSM_ACTIVE_STATUS_EVENT
@&view_dir.bl_fsm_active_status_event.vw


prompt - sequences
prompt . - sequence FSM_SEQ
@&sequence_dir.fsm_seq.seq

prompt . - sequence FSM_LOG_SEQ
@&sequence_dir.fsm_log_seq.seq

prompt - create package specifications
prompt . - package FSM_ADMIN
@&pkg_dir.fsm_admin.pks

prompt . - package FSM
@&pkg_dir.fsm.pks

prompt - create type implementations
prompt . - type FSM_TYPE
@&type_dir.fsm_type.tpb

prompt - create package implementations

prompt . - package FSM_ADMIN
@&pkg_dir.fsm_admin.pkb

prompt . - load initial data
@&script_dir.initial_data.sql

prompt . - create event and status packages
begin
  fsm_admin.create_event_package;
  fsm_admin.create_status_package;
end;
/

prompt - create parameters
@&script_dir.ParameterGroup_PIT.sql

prompt . - package fsm
@&pkg_dir.fsm.pkb