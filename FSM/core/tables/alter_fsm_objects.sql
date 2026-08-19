@&tools.check_has_column fsm_objects fsm_status_change_date "date"
comment on column fsm_objects.fsm_status_change_date is 'Date of the last actual status change of the object.';

@&tools.check_has_column fsm_objects fsm_fms_id "&ORA_NAME_TYPE."
comment on column fsm_objects.fsm_fms_id is 'Last monitor status detected by FSM_MONITOR.';

@&tools.check_has_column fsm_objects fsm_monitor_status_date "date"
comment on column fsm_objects.fsm_monitor_status_date is 'Date on which the current monitor status was detected or became effective.';

update fsm_objects
   set fsm_status_change_date = fsm_last_change_date
 where fsm_status_change_date is null;
