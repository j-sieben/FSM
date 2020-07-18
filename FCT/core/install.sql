prompt &TOOLKIT. core installation

define table_dir=&CORE_DIR.sql/tables/
define type_dir=&CORE_DIR.sql/types/
define view_dir=&CORE_DIR.sql/views/
define sequence_dir=&CORE_DIR.sql/sequences/
define plsql_dir=&CORE_DIR.plsql/

prompt - cleaning up installation
@&CORE_DIR.clean_up.sql

prompt - creating default messages
@&CORE_DIR.messages/&DEFAULT_LANGUAGE./create_messages.sql

prompt - create type specifications
prompt . - type &TOOLKIT._type
@&type_dir.fsm_type.tps

prompt - create tables
prompt . - table &TOOLKIT._CLASS
@&table_dir.fsm_class.tbl

prompt . - table &TOOLKIT._STATUS_GROUP
@&table_dir.fsm_status_group.tbl

prompt . - table &TOOLKIT._EVENT
@&table_dir.fsm_event.tbl

prompt . - table &TOOLKIT._STATUS
@&table_dir.fsm_status.tbl

prompt . - table &TOOLKIT._STATUS_2_EVENT
@&table_dir.fsm_transition.tbl

prompt . - table &TOOLKIT._OBJECT
@&table_dir.fsm_object.tbl

prompt . - table &TOOLKIT._LOG
@&table_dir.fsm_log.tbl

prompt . - table &TOOLKIT._STATUS_SEVERITY
@&table_dir.fsm_status_severity.tbl

prompt - create views
prompt . - view &TOOLKIT._HIERARCHY_VW
@&view_dir.fsm_hierarchy_vw.vw

--prompt . - view &TOOLKIT._FSL_LOG_VW
@&view_dir.fsm_fsl_log_vw.vw

prompt . - view BL_&TOOLKIT._ACTIVE_STATUS_EVENT
@&view_dir.bl_fsm_active_status_event.vw

--prompt . - view &TOOLKIT._NEXT_COMMANDS_VW
@&view_dir.fsm_next_commands_vw.vw

prompt - sequences
prompt . - sequence &TOOLKIT._seq
@&sequence_dir.fsm_seq.seq

prompt . - sequence &TOOLKIT._log_seq
@&sequence_dir.fsm_log_seq.seq

prompt - create package specifications
prompt . - package &TOOLKIT._ADMIN_PKG
@&plsql_dir.fsm_admin_pkg.pks

prompt . - package &TOOLKIT._PKG
@&plsql_dir.fsm_pkg.pks

prompt . - package &TOOLKIT._UTIL
@&plsql_dir.fsm_util.pks


prompt - create type implementations
prompt . - type &TOOLKIT._type
@&type_dir.fsm_type.tpb

prompt - create package implementations
prompt . - package &TOOLKIT._UTIL
@&plsql_dir.fsm_util.pkb

prompt . - package &TOOLKIT._ADMIN_PKG
@&plsql_dir.fsm_admin_pkg.pkb


prompt - create helper packages
prompt . - create event and status packages
begin
  &TOOLKIT._admin_pkg.create_event_package;
  &TOOLKIT._admin_pkg.create_status_package;
end;
/

prompt . - package &TOOLKIT._PKG
@&plsql_dir.fsm_pkg.pkb