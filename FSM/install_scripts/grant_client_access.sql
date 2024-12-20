/*
  Script to install FSM-CLIENT
  Usage:
  Call this script either directly or by using the bat/sh script files.
  
  Parameter:
  - REMOTE_USER:  database user who will be enabled to use PIT
*/
@tools/init_client.sql &1. &2.


prompt
prompt &section.
prompt &h1.Grant access to FSM to client &REMOTE_USER.
prompt &section.

@core/grant_client_access.sql

prompt &section.
prompt &h1.Finished FSM client grants
prompt &section.

exit
