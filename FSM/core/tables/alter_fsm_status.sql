declare
  procedure add_column(
    p_table_name in varchar2,
    p_column_name in varchar2,
    p_definition in varchar2)
  as
    l_count pls_integer;
  begin
    select count(*)
      into l_count
      from user_tab_cols
     where table_name = upper(p_table_name)
       and column_name = upper(p_column_name);

    if l_count = 0 then
      execute immediate 'alter table ' || p_table_name || ' add (' || p_column_name || ' ' || p_definition || ')';
    end if;
  end add_column;

  procedure add_constraint(
    p_table_name in varchar2,
    p_constraint_name in varchar2,
    p_definition in varchar2)
  as
    l_count pls_integer;
  begin
    select count(*)
      into l_count
      from user_constraints
     where table_name = upper(p_table_name)
       and constraint_name = upper(p_constraint_name);

    if l_count = 0 then
      execute immediate 'alter table ' || p_table_name || ' add constraint ' || p_constraint_name || ' ' || p_definition;
    end if;
  end add_constraint;

  procedure ensure_not_null(
    p_table_name in varchar2,
    p_column_name in varchar2,
    p_definition in varchar2)
  as
    l_nullable user_tab_cols.nullable%type;
  begin
    select nullable
      into l_nullable
      from user_tab_cols
     where table_name = upper(p_table_name)
       and column_name = upper(p_column_name);

    if l_nullable = 'Y' then
      execute immediate 'alter table ' || p_table_name || ' modify (' || p_column_name || ' ' || p_definition || ')';
    end if;
  end ensure_not_null;
begin
  add_column('FSM_STATUS', 'FST_WARN_INTERVAL', 'interval day to second');
  add_column('FSM_STATUS', 'FST_ALERT_INTERVAL', 'interval day to second');
  add_column('FSM_STATUS', 'FST_ESCALATION_BASIS', 'varchar2(128 byte) default ''STATUS''');
  add_column('FSM_STATUS', 'FST_TERMINAL_STATUS', 'char(1 byte) default ''N''');
  ensure_not_null('FSM_STATUS', 'FST_ESCALATION_BASIS', 'default ''STATUS'' not null');
  ensure_not_null('FSM_STATUS', 'FST_TERMINAL_STATUS', 'default ''N'' not null');
  add_constraint('FSM_STATUS', 'FST_ESCALATION_BASIS_CHK', q'[check (fst_escalation_basis in ('STATUS', 'EVENT'))]');
  add_constraint('FSM_STATUS', 'FST_TERMINAL_STATUS_CHK', q'[check (fst_terminal_status in ('Y', 'N'))]');
  add_constraint(
    'FSM_STATUS',
    'CHK_FST_ESCALATION_INTERVAL',
    q'[check (
         (fst_warn_interval is null and fst_alert_interval is null)
      or (fst_warn_interval is not null and fst_alert_interval is not null and fst_warn_interval < fst_alert_interval)
    )]');
end;
/

update fsm_status
   set fst_escalation_basis = 'STATUS'
 where fst_escalation_basis is null;

update fsm_status
   set fst_terminal_status = 'N'
 where fst_terminal_status is null;

comment on column fsm_status.fst_warn_interval is 'Optional lower threshold for the expected duration in this status before escalation to WARN.';
comment on column fsm_status.fst_alert_interval is 'Optional upper threshold for the expected duration in this status before escalation to ALERT.';
comment on column fsm_status.fst_escalation_basis is 'Determines whether elapsed time is measured from the last status change (STATUS) or the last successful event/activity (EVENT).';
comment on column fsm_status.fst_terminal_status is 'Flag indicating whether this status is a terminal/final status of the workflow';
