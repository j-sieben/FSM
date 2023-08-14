-- De-installation script for Finite State Machine implementation in PL/SQL
-- This script allows an abbreviation (please use 3 to 5 characters max) for the Finite State Machine
-- Default toolkit name. Please change with caution! Before changing it, remove any existing installation 
-- within the same schema.
define TOOLKIT=FSM

-- Params:
-- 1.: APEX workspace name
-- 1.: APP ID
@tools/init_apex.sql &1. &2.

define tool_dir=tools/
define sample_dir=sample_app/

prompt
prompt &section.
prompt &h1.FSM sample Apex application deinstallation at user &INSTALL_USER.
@&sample_dir.uninstall_sample_app.sql

prompt &h1.Finished FSM APEX application deinstallation

exit
