-- Deinstallation script for FSM client installation

-- Params:
-- 1.: Name of the database owner of the Toolkit
-- 2.: Name of the client user that wants to utilize the Toolkit
@tools/init_client.sql

define core_dir=core/

prompt
prompt &section.
prompt &h1.FSM Client Deinstallation for user &REMOTE_USER.
@&core_dir.clean_up_client.sql

prompt
prompt &section.
prompt &h1.Finalize installation

prompt &h1.Finished FSM Client Deinstallation

exit
