declare

  procedure drop_view_if_exists(
    p_view_name in varchar2)
  as
  begin
    execute immediate 'drop view ' || p_view_name;
  exception
    when others then
      if sqlcode != -942 then
        raise;
      end if;
  end drop_view_if_exists;


  procedure drop_package_if_exists(
    p_package_name in varchar2)
  as
  begin
    execute immediate 'drop package ' || p_package_name;
  exception
    when others then
      if sqlcode != -4043 then
        raise;
      end if;
  end drop_package_if_exists;

begin
  -- Drop views in reverse dependency order.
  drop_view_if_exists('BL_FSM_NEXT_COMMANDS');
  drop_view_if_exists('BL_FSM_HIERARCHY');
  drop_view_if_exists('BL_FSM_ACTIVE_STATUS_EVENT');
  drop_view_if_exists('FSM_FSL_LOG_V');
  drop_view_if_exists('FSM_LOG_V');
  drop_view_if_exists('FSM_OBJECTS_V');
  drop_view_if_exists('FSM_TRANSITIONS_V');
  drop_view_if_exists('FSM_STATUS_V');
  drop_view_if_exists('FSM_EVENTS_V');
  drop_view_if_exists('FSM_STATUS_SEVERITIES_V');
  drop_view_if_exists('FSM_STATUS_GROUPS_V');
  drop_view_if_exists('FSM_SUB_CLASSES_V');
  drop_view_if_exists('FSM_CLASSES_V');

  -- Drop generated and maintained packages so specs can be recreated cleanly.
  drop_package_if_exists('FSM_FEV');
  drop_package_if_exists('FSM_FST');
  drop_package_if_exists('FSM_ADMIN');
  drop_package_if_exists('FSM');
end;
/
