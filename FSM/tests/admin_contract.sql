prompt Running FSM administration and metadata contract tests

create or replace type fsm_admin_test_type under fsm_type();
/

declare
  C_TEST_CLASS constant pit_util.ora_name_type := 'ADT';
  l_fsm fsm_admin_test_type;
  l_count binary_integer;
  l_text clob;

  procedure assert_true(p_condition in boolean, p_test in varchar2) as
  begin
    if p_condition then
      dbms_output.put_line('PASS: ' || p_test);
    else
      raise_application_error(-20000, p_test);
    end if;
  end assert_true;

  procedure assert_equals(p_actual in varchar2, p_expected in varchar2, p_test in varchar2) as
  begin
    assert_true(
      p_actual = p_expected or p_actual is null and p_expected is null,
      p_test || ': expected [' || p_expected || '], got [' || p_actual || ']');
  end assert_equals;

  procedure cleanup as
  begin
    fsm_admin.delete_class(C_TEST_CLASS, true);
    pit_admin.delete_message_group(C_TEST_CLASS, true);
    commit;
  exception when others then rollback;
  end cleanup;
begin
  fsm_admin.merge_class(C_TEST_CLASS, 'FSM_ADMIN_TEST_TYPE', 'Admin test', 'Temporary FSM_ADMIN test class');
  fsm_admin.merge_status_group('FLOW', C_TEST_CLASS, 'Flow', 'Temporary test group');
  fsm_admin.merge_status(
    p_fst_id => 'READY', p_fst_fcl_id => C_TEST_CLASS, p_fst_fsg_id => 'FLOW',
    p_fst_name => 'Ready', p_fst_description => 'Initial test status',
    p_fst_severity => fsm.C_STORY_STEP, p_fst_msg_id => 'ADMIN_TEST_READY',
    p_fst_initial_status => true);
  fsm_admin.merge_status(
    p_fst_id => 'DONE', p_fst_fcl_id => C_TEST_CLASS, p_fst_fsg_id => 'FLOW',
    p_fst_name => 'Done', p_fst_description => 'Terminal test status',
    p_fst_severity => fsm.C_STORY_TERMINAL, p_fst_msg_id => 'ADMIN_TEST_DONE',
    p_fst_terminal_status => true);
  fsm_admin.merge_event(
    p_fev_id => 'FINISH', p_fev_fcl_id => C_TEST_CLASS,
    p_fev_name => 'Finish', p_fev_description => 'Complete the test FSM',
    p_fev_msg_id => 'ADMIN_TEST_FINISH', p_fev_raised_by_user => true);
  fsm_admin.merge_transition(
    p_ftr_fst_id => 'READY', p_ftr_fev_id => 'FINISH', p_ftr_fcl_id => C_TEST_CLASS,
    p_ftr_fst_list => 'DONE', p_ftr_raise_automatically => false);

  select count(*) into l_count from fsm_classes where fcl_id = C_TEST_CLASS;
  assert_equals(to_char(l_count), '1', 'merge_class persists the class');
  select count(*) into l_count from fsm_status where fst_fcl_id = C_TEST_CLASS;
  assert_equals(to_char(l_count), '2', 'merge_status persists both statuses');
  select count(*) into l_count from fsm_events where fev_fcl_id = C_TEST_CLASS;
  assert_equals(to_char(l_count), '1', 'merge_event persists the event');
  select count(*) into l_count from fsm_transitions where ftr_fcl_id = C_TEST_CLASS;
  assert_equals(to_char(l_count), '1', 'merge_transition persists the transition');

  l_fsm := fsm_admin_test_type(
             null, C_TEST_CLASS, 'MASTER', 'READY', null, null,
             fsm.C_OK, 'FINISH', pit_util.C_FALSE);
  assert_true(fsm.allows_event(l_fsm, 'FINISH'), 'allows_event accepts configured event');
  assert_true(not fsm.allows_event(l_fsm, 'UNKNOWN'), 'allows_event rejects unknown event');
  assert_equals(fsm.get_next_status(l_fsm, 'FINISH'), 'DONE', 'get_next_status resolves metadata target');

  fsm_admin.check_metadata(C_TEST_CLASS, 'MASTER');
  dbms_output.put_line('PASS: check_metadata accepts a complete flow');

  l_text := fsm_admin.export_class(C_TEST_CLASS);
  assert_true(dbms_lob.getlength(l_text) > 0, 'export_class returns content');
  assert_true(dbms_lob.instr(l_text, C_TEST_CLASS) > 0, 'export_class identifies the class');

  l_text := fsm_admin.get_class_diagram(C_TEST_CLASS, 'MASTER');
  assert_true(dbms_lob.instr(l_text, 'flowchart') > 0, 'class diagram is Mermaid');
  assert_true(dbms_lob.instr(l_text, 'READY') > 0, 'class diagram contains source status');
  assert_true(dbms_lob.instr(l_text, 'DONE') > 0, 'class diagram contains target status');

  cleanup;
exception when others then cleanup; raise;
end;
/

drop type fsm_admin_test_type;
