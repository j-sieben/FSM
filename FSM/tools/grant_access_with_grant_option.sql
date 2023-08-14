
begin
  if '&INSTALL_USER.' != '&REMOTE_USER.' then
    dbms_output.put_line('&s1.Granting &1. on &2. to &REMOTE_USER.');
    execute immediate 'grant &1. on &INSTALL_USER..&2. to &REMOTE_USER. with grant option';
  end if;
exception
  when others then
    dbms_output.put_line('&s1.Object &2. does not exist.');
end;
/
