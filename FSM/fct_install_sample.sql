-- Installation script for Finite State Machine sample application

-- Params:
-- 1.: Name of the database owner of the Toolkit
-- 2.: Default language for messages as an oracle language name (AMERICAN | GERMAN)

@init.sql

define tool_dir=tools/
define sample_dir=sample/

alter session set current_schema=sys;
prompt
prompt &section.
prompt &h1.Checking whether required users exist
@&tool_dir.check_users_exist.sql

prompt &h2.grant user rights
@set_grants.sql

alter session set current_schema=&INSTALL_USER.;

prompt
prompt &section.
prompt &h1.FSM Samples Installation at user &INSTALL_USER.
@&sample_dir.install.sql

prompt
prompt &section.
prompt &h1.Finalize installation

prompt &h2.Revoke user rights
@revoke_grants.sql

prompt The APEX application was not installed yet, import it to your workspace manually.
prompt It can be found at ./sample/APEX_application.sql
prompt
prompt &h1.Finished FSM Samples Installation

exit
