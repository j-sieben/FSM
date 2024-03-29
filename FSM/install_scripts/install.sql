-- installation script for Finite State Machine implementation in PL/SQL
-- This script allows an abbreviation (please use 3 to 5 characters max) for the Finite State Machine
-- Default toolkit name. Please change with caution! Before changing it, remove any existing installation 
-- within the same schema.
define TOOLKIT=FSM
define install_dir=install_scripts/
define tool_dir=tools/
define core_dir=core/

-- Params:
-- 1.: Name of the database owner of the Toolkit
-- 2.: Default language for messages as an oracle language name (AMERICAN | GERMAN)
@&tool_dir.init.sql &1. &2.

@&install_dir.check_prerequisites.sql

prompt
prompt &section.
prompt &h1.fsm Installation at user &INSTALL_USER.
@&core_dir.install.sql

prompt &h1.Finished fsm-Installation

exit