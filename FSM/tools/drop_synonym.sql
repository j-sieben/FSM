
begin
  if '&INSTALL_USER.' != '&REMOTE_USER.' then
    execute immediate 'drop synonym &1.';
    dbms_output.put_line('&s1.Synonym &1. for &INSTALL_USER..&1. at &REMOTE_USER. dropped');
  end if;
exception
  when others then 
    null; -- synonym does not exist, silently ignore
end;
/