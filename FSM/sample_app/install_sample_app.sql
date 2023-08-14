

define tool_dir=tools/
define table_dir=&sample_dir.tables/
define view_dir=&sample_dir.views/
define type_dir=&sample_dir.types/
define pkg_dir=&sample_dir.packages/
define script_dir=&sample_dir.scripts/
define msg_dir=&sample_dir.messages/&DEFAULT_LANGUAGE./
define apex_version_dir=&sample_dir.&APEX_PATH./

define FSM_CLASS=REQ

prompt &h2.Create synonyms for granted objects
@&tool_dir.create_synonym fsm_request_types_vw
@&tool_dir.create_synonym fsm_requestors_vw
@&tool_dir.create_synonym fsm_requests_vw
@&tool_dir.create_synonym bl_request
@&tool_dir.create_synonym fsm_req

prompt &h2.Create UI-Views
@&tool_dir.install_view fsm_lov_demo_user
@&tool_dir.install_view fsm_lov_severity
@&tool_dir.install_view fsm_lov_requestor
@&tool_dir.install_view fsm_lov_request_type
@&tool_dir.isntall_view fsm_ui_next_commands

prompt &h2.Create UI-Package
@&tool_dir.install_package_spec fsm_ui
@&tool_dir.install_package_body fsm_ui

prompt &h2.Install APEX application
@&apex_version_dir.install.sql