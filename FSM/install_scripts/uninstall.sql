-- installation script for Finite State Machine implementatino in PL/SQL
-- This script allows an abbreviation (please use 3 to 5 characters max) for the Finite State Machine
-- Default toolkit name. Please change with caution! Before changing it, remove any existing installation 
-- within the same schema.
define TOOLKIT=FSM

-- Params:
-- 1.: Name of the database owner of the Toolkit
-- 2.: Default language for messages as an oracle language name (AMERICAN | GERMAN)
@tools/init.sql

define core_dir=core/

prompt
prompt &section.
prompt &h1.fsm De-Installation at user &INSTALL_USER.
@&core_dir.uninstall.sql

prompt &h1.Finished fsm De-Installation

exit
