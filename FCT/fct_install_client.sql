-- installation script for Finite State Machine implementatino in PL/SQL
-- This script allows an abbreviation (please use 3 to 5 characters max) for the Finite State Machine
-- Default toolkit name. Please change with caution! Before changing it, remove any existing installation 
-- within the same schema.
define TOOLKIT=FSM

-- Params:
-- 1.: Name of the database owner of the Toolkit
-- 2.: Name of the client user that wants to utilize the Toolkit
@init_client.sql

define core_dir=core/

prompt
prompt &section.
prompt &h1.&TOOLKIT. Client Installation for user &REMOTE_USER.
@&core_dir.install_client.sql

prompt
prompt &section.
prompt &h1.Finalize installation

prompt &h1.Finished &TOOLKIT. Client Installation

exit
