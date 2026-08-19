set serveroutput on size unlimited
whenever sqlerror exit failure rollback

begin
  ut_runner.run(
    a_paths => ut_varchar2_list('FSM_CORE_TEST'),
    a_reporters => ut_reporters(ut_documentation_reporter()),
    a_fail_on_errors => true,
    a_force_manual_rollback => true);
  dbms_output.put_line('PASS: FSM_CORE_TEST');
end;
/

exit success
