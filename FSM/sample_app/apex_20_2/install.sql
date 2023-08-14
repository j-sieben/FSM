
define script_dir=&apex_version_dir.scripts/
define app_dir=&apex_version_dir.application/

prompt &h3.Install APEX-application from folder &APEX_PATH.
prompt &s1.Prepare installation
@&apex_version_dir.prepare_apex_import.sql

prompt &s1.Install application
@&app_dir.fsm.sql

set verify off