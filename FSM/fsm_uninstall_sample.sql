-- Deinstallation script for Finite State Machine sample application

-- Params:
-- 1.: Name of the database owner of the Toolkit
-- 2.: Default language for messages as an oracle language name (AMERICAN | GERMAN)

@tools/init.sql

define tool_dir=tools/
define sample_dir=sample/
define FSM_CLASS=REQ

alter session set current_schema=&INSTALL_USER.;

prompt
prompt &section.
prompt &h1.fsm samples deinstallation at user &INSTALL_USER.
prompt &h2.Deinstalling core functionality
@&sample_dir.clean_up.sql

prompt &h1.FSM Samples deinstalled

exit
