-- installation script for Finite State Machine implementation in PL/SQL
-- This script allows an abbreviation (please use 3 to 5 characters max) for the Finite State Machine
-- Default toolkit name. Please change with caution! Before changing it, remove any existing installation 
-- within the same schema.
define TOOLKIT=FSM

-- Params:
-- 1.: Name of the bl owner of FSM
-- 1.: Name of the APEX app owner of FSM
-- 1.: APEX Workspace
-- 1.: APEX app id
@tools/init_apex.sql &1. &2. &3. &4.

define tool_dir=tools/
define sample_dir=sample_app/

prompt
prompt &section.
prompt &h1.FSM sample APEX application installation at user &REMOTE_USER.
@&sample_dir.install_sample_app.sql

prompt &h1.Finished FSM sample APEX application installation

exit
