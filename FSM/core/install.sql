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

prompt - create type specifications
prompt . - type fsm_type
@&type_dir.fsm_type.tps

prompt - create tables
prompt . - table FSM_CLASS
@&table_dir.fsm_class.tbl

prompt . - table FSM_STATUS_GROUP
@&table_dir.fsm_status_group.tbl

prompt . - table FSM_EVENT
@&table_dir.fsm_event.tbl

prompt . - table FSM_STATUS
@&table_dir.fsm_status.tbl

prompt . - table FSM_TRANSITION
@&table_dir.fsm_transition.tbl

prompt . - table FSM_OBJECT
@&table_dir.fsm_object.tbl

prompt . - table FSM_LOG
@&table_dir.fsm_log.tbl

prompt . - table FSM_STATUS_SEVERITY
@&table_dir.fsm_status_severity.tbl


prompt - create views
prompt . - view FSM_HIERARCHY_VW
@&view_dir.fsm_hierarchy_vw.vw

prompt . - view FSM_FSL_LOG_VW
@&view_dir.fsm_fsl_log_vw.vw

prompt . - view BL_FSM_ACTIVE_STATUS_EVENT
@&view_dir.bl_fsm_active_status_event.vw

prompt . - view FSM_NEXT_COMMANDS_VW
@&view_dir.fsm_next_commands_vw.vw

prompt . - view FSM_OBJECT_VW
@&view_dir.fsm_object_vw.vw

prompt - sequences
prompt . - sequence FSM_SEQ
@&sequence_dir.fsm_seq.seq

prompt . - sequence FSM_LOG_SEQ
@&sequence_dir.fsm_log_seq.seq

prompt - create package specifications
prompt . - package FSM_ADMIN_PKG
@&pkg_dir.fsm_admin_pkg.pks

prompt . - package FSM_PKG
@&pkg_dir.fsm_pkg.pks


prompt - create type implementations
prompt . - type FSM_TYPE
@&type_dir.fsm_type.tpb

prompt - create package implementations

prompt . - package FSM_ADMIN_PKG
@&pkg_dir.fsm_admin_pkg.pkb

prompt . - load initial data
@&script_dir.initial_data.sql

prompt . - create event and status packages
begin
  fsm_admin_pkg.create_event_package;
  fsm_admin_pkg.create_status_package;
end;
/

prompt - create parameters
@&script_dir.ParameterGroup_PIT.sql

prompt . - package fsm_PKG
@&pkg_dir.fsm_pkg.pkb