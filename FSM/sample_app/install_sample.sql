
prompt
prompt &section.
prompt &h1.Installing FSM sample instance

define tool_dir=tools/
define table_dir=&sample_dir.tables/
define view_dir=&sample_dir.views/
define type_dir=&sample_dir.types/
define pkg_dir=&sample_dir.packages/
define script_dir=&sample_dir.scripts/
define msg_dir=&sample_dir.messages/&DEFAULT_LANGUAGE./

define FSM_CLASS=REQ

prompt &h2.Create FSM sample messages
@&msg_dir.create_messages.sql

prompt &h2.Create tables and initial data
@&tool_dir.check_has_table fsm_request_types
@&tool_dir.check_has_table fsm_requestors
@&tool_dir.check_has_table fsm_requests
@&tool_dir.check_has_table demo_users

prompt &h3.Create initial status, events and transitions
@&script_dir.create_fsm_data.sql

prompt &h3.Re-Create Packages FSM_FEV and FSM_FST
begin
  dbms_output.put_line('&s1.Create package FSM_FEV');
  fsm_admin.create_event_package;
  dbms_output.put_line('&s1.Create package FSM_FST');
  fsm_admin.create_status_package;
end;
/

prompt &h3.Create Views
@&tool_dir.install_view demo_users_vw
@&tool_dir.install_view fsm_requests_vw
@&tool_dir.install_view fsm_requestors_vw
@&tool_dir.install_view fsm_request_types_vw

prompt &h3.Create type declarations
@&tool_dir.install_type_spec fsm_req_type

prompt &h3.Create package declarations
@&tool_dir.install_package_spec fsm_req
@&tool_dir.install_package_spec bl_request

prompt &h3.Create type bodies
@&tool_dir.install_type_body fsm_req_type

prompt &h3.Create package bodies
@&tool_dir.install_package_body fsm_req
@&tool_dir.install_package_body bl_request

prompt Create REQUEST related data
@&script_dir.create_request_data.sql

prompt Prepare installation of APEX application by granting access
@&sample_dir.grant_apex_access.sql
