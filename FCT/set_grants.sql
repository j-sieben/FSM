
prompt &h3.Grant SYSTEM privileges
prompt &s1.create session, create procedure, create table, create type, create view to &INSTALL_USER.
grant create session, create procedure, create table, create view, create type to &INSTALL_USER.;

prompt &h3.Grant OBJECT privileges
prompt &s1.grant select on V$SESSION
grant select on v_$session to &INSTALL_USER.;

begin
  $IF dbms_db_version.ver_le_11 $THEN
  null;
  $ELSE
  dbms_output.put_line('&s1.INHERIT PRIVILEGES from SYS to &INSTALL_USER. granted');
  execute immediate 'grant inherit privileges on user sys to &INSTALL_USER.';
  $END
end;
/

grant execute on dbms_lock to &INSTALL_USER.;
