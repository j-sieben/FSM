/*
  Drops an optional FSM monitor job from the consuming schema.

  Parameter:
  1. Local scheduler job name (unqualified SQL identifier)

  Example:
    @FSM/install_scripts/optional/drop_monitor_job.sql FSM_MONITOR_ORDER
*/

set verify off
set serveroutput on
whenever sqlerror exit failure rollback

declare
  l_job_name varchar2(128) := upper(trim('&1.'));
  l_count binary_integer;
begin
  l_job_name := dbms_assert.simple_sql_name(l_job_name);

  select count(*)
    into l_count
    from user_scheduler_jobs
   where job_name = l_job_name;

  if l_count = 0 then
    dbms_output.put_line('Scheduler job does not exist: ' || l_job_name);
  else
    dbms_scheduler.drop_job(
      job_name => l_job_name,
      force => false);
    dbms_output.put_line('Dropped scheduler job ' || l_job_name || '.');
  end if;
end;
/

