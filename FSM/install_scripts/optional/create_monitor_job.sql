/*
  Creates an optional, initially disabled scheduler job in the consuming schema.

  Prerequisites:
  - The consuming schema is registered as an FSM client.
  - CREATE JOB was granted directly to the consuming schema.

  Parameters:
  1. Local scheduler job name (unqualified SQL identifier)
  2. DBMS_SCHEDULER calendaring expression

  Example:
    @FSM/install_scripts/optional/create_monitor_job.sql FSM_MONITOR_ALL "FREQ=MINUTELY;INTERVAL=1"

  The job calls FSM_MONITOR.SCAN_ALL. It evaluates every FSM class with at least
  one configured warning or alert interval and persists and logs monitor status
  changes without instantiating concrete FSM object types.
*/

set verify off
set serveroutput on
whenever sqlerror exit failure rollback

declare
  l_job_name varchar2(128) := upper(trim('&1.'));
  l_repeat_interval varchar2(4000) := trim('&2.');
  l_count binary_integer;
begin
  l_job_name := dbms_assert.simple_sql_name(l_job_name);

  if l_repeat_interval is null then
    raise_application_error(-20000, 'Scheduler repeat interval must not be empty.');
  end if;

  select count(*)
    into l_count
    from user_scheduler_jobs
   where job_name = l_job_name;

  if l_count > 0 then
    raise_application_error(-20000, 'Scheduler job already exists: ' || l_job_name);
  end if;

  dbms_scheduler.create_job(
    job_name => l_job_name,
    job_type => 'PLSQL_BLOCK',
    job_action => 'begin fsm_monitor.scan_all; end;',
    start_date => systimestamp,
    repeat_interval => l_repeat_interval,
    enabled => false,
    auto_drop => false,
    comments => 'Optional deadline monitor for all configured FSM classes');

  dbms_output.put_line('Created disabled scheduler job ' || l_job_name || '.');
  dbms_output.put_line('Enable explicitly with: exec dbms_scheduler.enable(''' || l_job_name || ''');');
exception
  when others then
    if sqlcode = -27486 then
      raise_application_error(
        -20000,
        'CREATE JOB is required in the consuming schema. Original error: ' || sqlerrm);
    end if;
    raise;
end;
/
