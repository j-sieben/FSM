@common.sql

define INSTALL_USER = &1.;
define TABLESPACE = &2.;

define core_dir=core/
define sample_dir=sample/

alter session set current_schema=sys;
prompt
prompt &section.
prompt &h1.Checking whether required users exist
@check_users_exist.sql

prompt &h2.grant user rights
@set_grants.sql

alter session set current_schema=&INSTALL_USER.;

prompt
prompt &section.
prompt &h1.&TOOLKIT. (Flow Control Toolkit) Installation at user &INSTALL_USER.
prompt &h2.Installing core functionality
@&core_dir.install.sql

prompt
prompt &section.
prompt &h1.Installing &TOOLKIT. sample instance
@&sample_dir.install.sql

prompt
prompt &section.
prompt &h2.Checking &TOOLKIT. INSTALLATION
--@check_installation.sql

prompt
prompt &section.
prompt &h1.Finalize installation
prompt &h2.Revoke user rights
@revoke_grants.sql

prompt &h1.Finished &TOOLKIT.-Installation

exit
