@&tools.check_has_column fsm_objects fsm_status_change_date "date"
comment on column fsm_objects.fsm_status_change_date is 'Date of the last actual status change of the object.';

update fsm_objects
   set fsm_status_change_date = fsm_last_change_date
 where fsm_status_change_date is null;
