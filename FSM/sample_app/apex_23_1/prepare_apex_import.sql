declare
  l_workspace_id number;
begin
  select workspace_id 
    into l_workspace_id
    from apex_workspaces
   where workspace = '&APEX_WS.';
    
  apex_application_install.generate_application_id;
  if '&APP_ID.' is not null then
    apex_application_install.set_application_id(&APP_ID.);
  end if;
  apex_application_install.set_workspace_id(l_workspace_id);
  apex_application_install.generate_offset;
  apex_application_install.set_schema(user);
end;
/