declare
  l_count pls_integer;
begin
  select count(*)
    into l_count
    from user_tab_cols
   where table_name = 'FSM_OBJECTS'
     and column_name = 'FSM_STATUS_CHANGE_DATE';

  if l_count = 0 then
    execute immediate 'alter table fsm_objects add (fsm_status_change_date date)';
  end if;
end;
/

update fsm_objects
   set fsm_status_change_date = fsm_last_change_date
 where fsm_status_change_date is null;

comment on column fsm_objects.fsm_last_change_date is 'Date of the last successful activity or event affecting the object.';
comment on column fsm_objects.fsm_status_change_date is 'Date of the last actual status change of the object.';
