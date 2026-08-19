update fsm_objects
   set fsm_fms_id = 'OK',
       fsm_monitor_status_date = coalesce(fsm_status_change_date, fsm_last_change_date, sysdate)
 where fsm_fms_id is null
    or fsm_monitor_status_date is null;

commit;

declare
  l_nullable user_tab_cols.nullable%type;
  l_default_on_null user_tab_cols.default_on_null%type;
  l_index_count binary_integer;
begin
  select nullable, default_on_null
    into l_nullable, l_default_on_null
    from user_tab_cols
   where table_name = 'FSM_OBJECTS'
     and column_name = 'FSM_FMS_ID';

  if l_default_on_null = 'NO' then
    execute immediate q'[alter table fsm_objects modify fsm_fms_id default on null 'OK']';
  elsif l_nullable = 'Y' then
    execute immediate 'alter table fsm_objects modify fsm_fms_id not null';
  end if;

  select nullable, default_on_null
    into l_nullable, l_default_on_null
    from user_tab_cols
   where table_name = 'FSM_OBJECTS'
     and column_name = 'FSM_MONITOR_STATUS_DATE';

  if l_default_on_null = 'NO' then
    execute immediate 'alter table fsm_objects modify fsm_monitor_status_date default on null sysdate';
  elsif l_nullable = 'Y' then
    execute immediate 'alter table fsm_objects modify fsm_monitor_status_date not null';
  end if;

  select count(*)
    into l_index_count
    from user_indexes
   where table_name = 'FSM_OBJECTS'
     and index_name = 'IDX_FK_FSM_FMS_ID';

  if l_index_count = 0 then
    execute immediate 'create index idx_fk_fsm_fms_id on fsm_objects (fsm_fms_id)';
  end if;
end;
/

@&tools.check_has_constraint fsm_objects fk_fsm_fms_id "foreign key (fsm_fms_id) references fsm_monitor_status (fms_id)"
