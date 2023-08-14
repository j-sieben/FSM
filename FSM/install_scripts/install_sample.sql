-- installation script for Finite State Machine implementation in PL/SQL
-- This script allows an abbreviation (please use 3 to 5 characters max) for the Finite State Machine
-- Default toolkit name. Please change with caution! Before changing it, remove any existing installation 
-- within the same schema.
define TOOLKIT=REQ

-- Params:
-- 1.: Name of the BL owner owner of the Sample app
-- 1.: Name of the APEX owner of the Sample App
@tools/init.sql &1. &2.

define tool_dir=tools/
define sample_dir=sample_app/

prompt
prompt &section.
prompt &h1.FSM sample business logic installation at user &INSTALL_USER.
@&sample_dir.install_sample.sql

prompt &h1.Finished FSM sample business logic installation

exit
