declare
  l_count pls_integer;
  l_nullable user_tab_cols.nullable%type;
  l_null_count pls_integer;
  l_duplicate_count pls_integer;
begin
  select count(*)
    into l_count
    from user_tab_cols
   where table_name = 'FSM_CLASSES'
     and column_name = 'FCL_TYPE_NAME';

  if l_count = 0 then
    execute immediate 'alter table fsm_classes add (fcl_type_name varchar2(128 byte))';
  end if;
end;
/

update fsm_classes
   set fcl_type_name = case
                         when fcl_id = 'FSM' then 'FSM_TYPE'
                         else 'FSM_' || fcl_id || '_TYPE'
                       end
 where fcl_type_name is null;

declare
  l_count pls_integer;
  l_nullable user_tab_cols.nullable%type;
  l_null_count pls_integer;
  l_duplicate_count pls_integer;
begin
  select count(*)
    into l_null_count
    from fsm_classes
   where fcl_type_name is null;

  select count(*)
    into l_duplicate_count
    from (
      select fcl_type_name
        from fsm_classes
       where fcl_type_name is not null
       group by fcl_type_name
      having count(*) > 1);

  select nullable
    into l_nullable
    from user_tab_cols
   where table_name = 'FSM_CLASSES'
     and column_name = 'FCL_TYPE_NAME';

  if l_nullable = 'Y' and l_null_count = 0 then
    execute immediate 'alter table fsm_classes modify (fcl_type_name not null)';
  end if;

  select count(*)
    into l_count
    from user_constraints
   where table_name = 'FSM_CLASSES'
     and constraint_name = 'UQ_FSM_CLASSES_TYPE_NAME';

  if l_count = 0 and l_null_count = 0 and l_duplicate_count = 0 then
    execute immediate 'alter table fsm_classes add constraint uq_fsm_classes_type_name unique (fcl_type_name)';
  end if;
end;
/

comment on column fsm_classes.fcl_type_name is 'Name of the implementing SQL object type. Used to derive class ownership from ALL_TYPES.';
