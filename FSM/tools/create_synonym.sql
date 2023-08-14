begin
  if '&INSTALL_USER.' != user then
    execute immediate 'create or replace synonym &1. for &INSTALL_USER..&1.';
    dbms_output.put_line('&s1.Create synonym &1.');
  end if;
end;
/
