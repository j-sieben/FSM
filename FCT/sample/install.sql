
prompt
prompt &section.
prompt &h1.Installing &TOOLKIT. sample instance

define sql_dir=&sample_dir.sql/
define plsql_dir=&sample_dir.plsql/

define FSM_CLASS=REQ

prompt &h2.Installing sample application
prompt &h3.Remove existing installation
@&sample_dir.clean_up_install.sql

prompt &s1.Create &TOOLKIT. sample messages
@&sample_dir./messages/&DEFAULT_LANGUAGE./create_messages.sql

prompt &h3.Create initial status, events and transitions
@&sample_dir.create_initial_data.sql

prompt &h3.Re-Create Packages &TOOLKIT._FEV and &TOOLKIT._FST
prompt &s1.Create package &TOOLKIT._FEV
begin
  &TOOLKIT._admin_pkg.create_event_package;
end;
/

prompt &s1.Create package &TOOLKIT._FST
begin
  &TOOLKIT._admin_pkg.create_status_package;
end;
/

prompt &s1.Create Parameters
@&sample_dir./create_parameters.sql

prompt &h3.Create tables and initial data
prompt &s1.Create table &TOOLKIT._REQ_TYPES
@&sql_dir.fsm_req_types.tbl
prompt &s1.Create table &TOOLKIT._REQ_REQUESTOR
@&sql_dir.fsm_req_requestor.tbl
prompt &s1.Create table &TOOLKIT._REQ_OBJECT
@&sql_dir.fsm_req_object.tbl
prompt &s1.Create table DEMO_USER
@&sql_dir.demo_user.tbl

prompt &h3.Create Views
prompt &s1.Create view &TOOLKIT._REQ_OBJECT_VW
@&sql_dir.fsm_req_object_vw.vw

prompt &h3.Create type declarations
prompt &s1.Create type &TOOLKIT._REQ_TYPE
@&sql_dir.fsm_req_type.tps
show errors

prompt &h3.Create package declarations
prompt &s1.Create package &TOOLKIT._REQ_PKG
@&plsql_dir.fsm_req_pkg.pks
show errors

prompt &h3.Create type bodies
prompt &s1.Create type body &TOOLKIT._REQ_TYPE
@&sql_dir.fsm_req_type.tpb
show errors

prompt &h3.Create package bodies
prompt &s1.Create package body &TOOLKIT._REQ_PKG
@&plsql_dir.fsm_req_pkg.pkb
show errors
