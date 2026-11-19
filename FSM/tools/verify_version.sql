-- Fail the installation if either FSM unit is invalid/missing or values differ.
whenever sqlerror exit failure rollback
set serveroutput on

declare
  l_count pls_integer;
begin
  select count(*) into l_count
    from user_objects
   where object_name = 'FSM'
     and object_type in ('PACKAGE', 'PACKAGE BODY')
     and status = 'VALID';
  if l_count != 2 then
    raise_application_error(-20000, 'FSM specification/body is missing or invalid');
  end if;
end;
/

declare
  l_version varchar2(40);
  l_commit varchar2(64);
begin
  -- Exercise the public SQL API as well as comparing the installed constants.
  select fsm.get_version, fsm.get_git_commit
    into l_version, l_commit
    from dual;
  if l_version is null or l_version != '&FSM_VERSION.' or
     l_commit is null or l_commit != '&FSM_GIT_COMMIT.' then
    raise_application_error(-20000, 'Installed FSM version does not match installation source');
  end if;
  dbms_output.put_line('Installed FSM ' || l_version);
  dbms_output.put_line('Git commit: ' || l_commit);
end;
/
