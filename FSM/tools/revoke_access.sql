
begin
  if '&INSTALL_USER.' != '&REMOTE_USER.' then
    execute immediate 'revoke &1. on &INSTALL_USER..&2. from &REMOTE_USER.';
    dbms_output.put_line('&s1.Grant &1. on &2. revoked from &REMOTE_USER.');
  end if;
exception
  when others then 
    null; -- grant does not exist, silently ignore
end;
/