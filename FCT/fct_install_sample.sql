-- installation script for Finite State Machine implementation in PL/SQL
-- This script allows an abbreviation (please use 3 to 5 characters max) for the Finite State Machine
-- Default toolkit name. Please change with caution! Before changing it, remove any existing installation 
-- within the same schema.
define TOOLKIT=FSM

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
prompt &h1.&TOOLKIT. samples Installation at user &INSTALL_USER.
prompt &h2.Installing core functionality
@&sample_dir.install.sql

prompt
prompt &section.
prompt &h1.Finalize installation

prompt &h2.Revoke user rights
@revoke_grants.sql

prompt &h1.Finished &TOOLKIT.-Samples Installation

exit
