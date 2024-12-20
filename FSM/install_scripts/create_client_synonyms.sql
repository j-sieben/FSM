/*
  Script to install FSM-CLIENT
  Usage:
  Call this script either directly or by using the bat/sh script files.
  
  Parameter:
  - REMOTE_USER:  database user who will be enabled to use FSM
*/


@tools/init_client.sql &1. &2.

prompt
prompt &section.
prompt &h1.Registering FSM, found at &INSTALL_USER. at client &REMOTE_USER.
prompt &section.
prompt &h2.Checking whether FSM exists at user &INSTALL_USER.
    
set termout off

declare
  l_fsm_exists binary_integer;
begin
  select count(*)
    into l_fsm_exists
    from all_objects
   where object_type = 'PACKAGE'
     and object_name = 'FSM'
     and owner = '&INSTALL_USER.';
     
  if l_fsm_exists = 0 then
    raise_application_error(-20000, 'No FSM installation found. Check whether the grants have been set.');
  end if;
end;
/

set termout on

prompt &h2.Creating synonyms for FSM at client &REMOTE_USER.
@core/register_client.sql

prompt &section.
prompt &h1.Finished FSM client registration
prompt &section.

exit

