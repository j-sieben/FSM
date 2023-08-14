-- Deinstallation script for FSM client installation

@tools/init_client.sql

define core_dir=core/

prompt
prompt &section.
prompt &h1.FSM Client Deinstallation for user &REMOTE_USER.
@&core_dir.uninstall_client.sql

prompt &h1.Finished FSM Client Deinstallation

exit
