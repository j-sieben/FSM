-- Run only in a disposable FSM owner with PIT persistent diagnostics configured.
set define on
set serveroutput on size unlimited
whenever oserror exit failure rollback
whenever sqlerror exit failure rollback
variable old_boolean number
variable old_local number
begin
  if param.get_boolean('AUTO_COMMIT', 'FSM') then :old_boolean := 1; else :old_boolean := 0; end if;
  select case when par_is_local = pit_util.C_TRUE then 1 else 0 end
    into :old_local from parameter_v where par_id = 'AUTO_COMMIT' and par_pgr_id = 'FSM';
end;
/
@@install.sql
@@mode.sql FALSE
@@mode.sql TRUE
@@call_boundary.sql
begin
  if :old_local = 1 then
    param.set_boolean('AUTO_COMMIT', 'FSM', :old_boolean = 1);
  else
    param.reset_parameter('AUTO_COMMIT', 'FSM');
  end if;
  commit;
  dbms_session.reset_package;
end;
/
@@uninstall.sql
exit success
