
prompt
prompt &section.
prompt &h1.Installing fsm sample instance

define table_dir=&sample_dir.tables/
define view_dir=&sample_dir.views/
define type_dir=&sample_dir.types/
define pkg_dir=&sample_dir.packages/
define script_dir=&sample_dir.scripts/
define msg_dir=&sample_dir.messages/&DEFAULT_LANGUAGE./

define FSM_CLASS=REQ

alter session set current_schema=&INSTALL_USER.;

prompt &h2.Installing sample application
prompt &h3.Remove existing installation
@&sample_dir.clean_up_install.sql

prompt &s1.Create fsm sample messages
@&msg_dir.create_messages.sql

prompt &h3.Create initial status, events and transitions
@&script_dir.create_initial_data.sql

prompt &h3.Re-Create Packages fsm_FEV and fsm_FST
prompt &s1.Create package fsm_FEV
begin
  fsm_admin_pkg.create_event_package;
end;
/

prompt &s1.Create package fsm_FST
begin
  fsm_admin_pkg.create_status_package;
end;
/

prompt &h3.Create tables and initial data
prompt &s1.Create table fsm_REQ_TYPES
@&table_dir.fsm_req_types.tbl
prompt &s1.Create table fsm_REQ_REQUESTOR
@&table_dir.fsm_req_requestor.tbl
prompt &s1.Create table fsm_REQ_OBJECT
@&table_dir.fsm_req_object.tbl
prompt &s1.Create table DEMO_USER
@&table_dir.demo_user.tbl

prompt &h3.Create Views
prompt &s1.Create view fsm_REQ_OBJECT_VW
@&view_dir.fsm_req_object_vw.vw

prompt &h3.Create type declarations
prompt &s1.Create type fsm_REQ_TYPE
@&type_dir.fsm_req_type.tps
show errors

prompt &h3.Create package declarations
prompt &s1.Create package fsm_REQ_PKG
@&pkg_dir.fsm_req_pkg.pks
show errors

prompt &h3.Create type bodies
prompt &s1.Create type body fsm_REQ_TYPE
@&type_dir.fsm_req_type.tpb
show errors

prompt &h3.Create package bodies
prompt &s1.Create package body fsm_REQ_PKG
@&pkg_dir.fsm_req_pkg.pkb
show errors
