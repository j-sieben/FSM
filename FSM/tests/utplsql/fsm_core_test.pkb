create or replace package body fsm_core_test as
  C_CLASS constant pit_util.ora_name_type := 'FUT';

  function new_fsm(p_sub_class in varchar2 default 'MASTER') return fsm_ut_type as
    l_fsm fsm_ut_type;
  begin
    l_fsm := fsm_ut_type(
               null, C_CLASS, p_sub_class, null, null, null,
               fsm.C_OK, null, pit_util.C_FALSE);
    fsm.initialize(l_fsm);
    return l_fsm;
  end new_fsm;

  function trace_for(p_fsm_id in number) return varchar2 as
    l_trace varchar2(4000);
  begin
    select listagg(trace_event, ':') within group(order by trace_id)
      into l_trace
      from fsm_ut_trace
     where fsm_id = p_fsm_id;
    return l_trace;
  end trace_for;

  procedure create_metadata as
  begin
    fsm_admin.merge_class(C_CLASS, 'FSM_UT_TYPE', 'FSM runtime test', 'Temporary utPLSQL runtime class');
    fsm_admin.merge_sub_class('AUTO', C_CLASS, 'Automatic', 'Automatic event test flow');
    fsm_admin.merge_sub_class('RETRY', C_CLASS, 'Retry', 'Retry and error test flow');
    fsm_admin.merge_status_group('FLOW', C_CLASS, 'Flow', 'Runtime test states');
    fsm_admin.merge_status(
      p_fst_id => 'START', p_fst_fcl_id => C_CLASS, p_fst_fsg_id => 'FLOW',
      p_fst_name => 'Start', p_fst_description => 'Initial state',
      p_fst_severity => fsm.C_STORY_STEP, p_fst_msg_id => 'FUT_START',
      p_fst_retries_on_error => 2, p_fst_retry_time => 0,
      p_fst_initial_status => true);
    fsm_admin.merge_status(
      p_fst_id => 'MIDDLE', p_fst_fcl_id => C_CLASS, p_fst_fsg_id => 'FLOW',
      p_fst_name => 'Middle', p_fst_description => 'Intermediate state',
      p_fst_severity => fsm.C_STORY_STEP, p_fst_msg_id => 'FUT_MIDDLE');
    fsm_admin.merge_status(
      p_fst_id => 'DONE', p_fst_fcl_id => C_CLASS, p_fst_fsg_id => 'FLOW',
      p_fst_name => 'Done', p_fst_description => 'Terminal state',
      p_fst_severity => fsm.C_STORY_TERMINAL, p_fst_msg_id => 'FUT_DONE',
      p_fst_terminal_status => true);
    fsm_admin.merge_status(
      p_fst_id => 'ERROR', p_fst_fcl_id => C_CLASS, p_fst_fsg_id => 'FLOW',
      p_fst_name => 'Error', p_fst_description => 'Deterministic fallback state',
      p_fst_severity => fsm.C_STORY_ERROR, p_fst_msg_id => msg.FSM_FINAL_STATE,
      p_fst_terminal_status => true);
    fsm_admin.merge_event('ADVANCE', C_CLASS, 'Advance', 'Advance the FSM', 'FUT_ADVANCE');
    fsm_admin.merge_event('FINISH', C_CLASS, 'Finish', 'Finish the FSM', 'FUT_FINISH');
    fsm_admin.merge_event('AUTO', C_CLASS, 'Automatic', 'Automatic completion', 'FUT_AUTO');
    fsm_admin.merge_event('RECOVER', C_CLASS, 'Recover', 'Configured error event', 'FUT_RECOVER');
    fsm_admin.merge_transition('START', 'ADVANCE', C_CLASS, 'MASTER', 'MIDDLE', false);
    fsm_admin.merge_transition('MIDDLE', 'FINISH', C_CLASS, 'MASTER', 'DONE', false);
    fsm_admin.merge_transition('START', 'AUTO', C_CLASS, 'AUTO', 'DONE', true);
    fsm_admin.merge_transition('START', 'ADVANCE', C_CLASS, 'RETRY', 'MIDDLE', false);
    fsm_admin.merge_transition('MIDDLE', 'FINISH', C_CLASS, 'RETRY', 'DONE', false);
    fsm_admin.merge_transition(
      p_ftr_fst_id => 'START', p_ftr_fev_id => 'RECOVER', p_ftr_fcl_id => C_CLASS,
      p_ftr_fsc_id => 'RETRY', p_ftr_fst_list => 'ERROR',
      p_ftr_raise_automatically => false, p_ftr_raise_on_status => fsm.C_ERROR);
    commit;
  end create_metadata;

  procedure remove_metadata as
  begin
    delete from fsm_objects where fsm_fcl_id = C_CLASS;
    delete from fsm_ut_trace;
    fsm_admin.delete_class(C_CLASS, true);
    pit_admin.delete_message_group(C_CLASS, true);
    commit;
  end remove_metadata;

  procedure reset_fixture as
  begin
    delete from fsm_objects where fsm_fcl_id = C_CLASS;
    delete from fsm_ut_trace;
    delete from fsm_transitions
     where ftr_fcl_id = C_CLASS
       and ftr_fsc_id = 'RETRY'
       and ftr_fev_id = 'AUTO';
    update fsm_transitions
       set ftr_fst_list = 'MIDDLE'
     where ftr_fcl_id = C_CLASS
       and ftr_fsc_id = 'MASTER'
       and ftr_fst_id = 'START'
       and ftr_fev_id = 'ADVANCE';
    update fsm_status
       set fst_initial_status = pit_util.C_TRUE
     where fst_fcl_id = C_CLASS
       and fst_id = 'START';
    commit;
  end reset_fixture;

  procedure initialize_instance as
    l_fsm fsm_ut_type;
    l_status varchar2(30);
    l_events varchar2(500);
  begin
    l_fsm := new_fsm;
    select fsm_fst_id, fsm_fev_list into l_status, l_events
      from fsm_objects where fsm_id = l_fsm.fsm_id;
    ut.expect(l_status).to_equal('START');
    ut.expect(l_events).to_equal('ADVANCE');
    ut.expect(trace_for(l_fsm.fsm_id)).to_equal('BEFORE:PERSIST:ENTER:AFTER');
  end initialize_instance;

  procedure transition_lifecycle as
    l_fsm fsm_ut_type;
    l_result number;
  begin
    l_fsm := new_fsm;
    delete from fsm_ut_trace where fsm_id = l_fsm.fsm_id;
    commit;
    l_result := l_fsm.raise_event('ADVANCE');
    ut.expect(l_result).to_equal(fsm.C_OK);
    ut.expect(l_fsm.fsm_fst_id).to_equal('MIDDLE');
    ut.expect(l_fsm.fsm_fev_list).to_equal('FINISH');
    ut.expect(trace_for(l_fsm.fsm_id)).to_equal('LEAVE:BEFORE:PERSIST:ENTER:AFTER');
  end transition_lifecycle;

  procedure unchanged_status as
    l_fsm fsm_ut_type;
    l_result number;
  begin
    l_fsm := new_fsm;
    delete from fsm_ut_trace where fsm_id = l_fsm.fsm_id;
    commit;
    l_result := l_fsm.set_status('START');
    ut.expect(l_result).to_equal(fsm.C_OK);
    ut.expect(trace_for(l_fsm.fsm_id)).to_equal('BEFORE:PERSIST:AFTER');
  end unchanged_status;

  procedure automatic_event_chain as
    l_fsm fsm_ut_type;
  begin
    l_fsm := new_fsm('AUTO');
    ut.expect(l_fsm.fsm_fst_id).to_equal('DONE');
    ut.expect(trace_for(l_fsm.fsm_id)).to_equal(
      'BEFORE:PERSIST:ENTER:AFTER:LEAVE:BEFORE:PERSIST:ENTER:AFTER:FINALIZE');
  end automatic_event_chain;

  procedure terminal_transition as
    l_fsm fsm_ut_type;
    l_result number;
  begin
    l_fsm := new_fsm;
    l_result := l_fsm.raise_event('ADVANCE');
    delete from fsm_ut_trace where fsm_id = l_fsm.fsm_id;
    commit;
    l_result := l_fsm.raise_event('FINISH');
    ut.expect(l_result).to_equal(fsm.C_OK);
    ut.expect(l_fsm.fsm_fst_id).to_equal('DONE');
    ut.expect(trace_for(l_fsm.fsm_id)).to_equal('LEAVE:BEFORE:PERSIST:ENTER:AFTER:FINALIZE');
  end terminal_transition;

  procedure unknown_escalation_state as
  begin
    ut.expect(fsm.get_escalation_state(-1)).to_be_null;
  end unknown_escalation_state;

  procedure invalid_status_fallback as
    l_fsm fsm_ut_type;
    l_result number;
    l_status varchar2(30);
  begin
    l_fsm := new_fsm;
    l_result := l_fsm.set_status('UNKNOWN_STATUS');
    select fsm_fst_id into l_status from fsm_objects where fsm_id = l_fsm.fsm_id;
    ut.expect(l_result).to_equal(fsm.C_OK);
    ut.expect(l_status).to_equal('ERROR');
  end invalid_status_fallback;

  procedure activity_timestamp as
    l_fsm fsm_ut_type;
    l_result number;
    l_activity_date date;
    l_status_date date;
    C_OLD_ACTIVITY constant date := date '2020-01-01';
    C_OLD_STATUS constant date := date '2020-01-02';
  begin
    l_fsm := new_fsm;
    update fsm_objects
       set fsm_last_change_date = C_OLD_ACTIVITY,
           fsm_status_change_date = C_OLD_STATUS
     where fsm_id = l_fsm.fsm_id;
    commit;
    l_result := l_fsm.set_status('START');
    select fsm_last_change_date, fsm_status_change_date
      into l_activity_date, l_status_date
      from fsm_objects where fsm_id = l_fsm.fsm_id;
    ut.expect(l_activity_date).to_be_greater_than(C_OLD_ACTIVITY);
    ut.expect(l_status_date).to_equal(C_OLD_STATUS);
  end activity_timestamp;

  procedure transition_timestamps as
    l_fsm fsm_ut_type;
    l_result number;
    l_activity_date date;
    l_status_date date;
    C_OLD_DATE constant date := date '2020-01-01';
  begin
    l_fsm := new_fsm;
    update fsm_objects
       set fsm_last_change_date = C_OLD_DATE,
           fsm_status_change_date = C_OLD_DATE
     where fsm_id = l_fsm.fsm_id;
    commit;
    l_result := l_fsm.raise_event('ADVANCE');
    select fsm_last_change_date, fsm_status_change_date
      into l_activity_date, l_status_date
      from fsm_objects where fsm_id = l_fsm.fsm_id;
    ut.expect(l_activity_date).to_be_greater_than(C_OLD_DATE);
    ut.expect(l_status_date).to_be_greater_than(C_OLD_DATE);
  end transition_timestamps;

  procedure missing_next_status as
    l_fsm fsm_ut_type;
  begin
    l_fsm := new_fsm;
    ut.expect(fsm.get_next_status(l_fsm, 'UNKNOWN_EVENT')).to_be_null;
  end missing_next_status;

  procedure ambiguous_next_status as
    l_fsm fsm_ut_type;
  begin
    l_fsm := new_fsm;
    update fsm_transitions
       set ftr_fst_list = 'MIDDLE:DONE'
     where ftr_fcl_id = C_CLASS
       and ftr_fsc_id = 'MASTER'
       and ftr_fst_id = 'START'
       and ftr_fev_id = 'ADVANCE';
    commit;
    ut.expect(fsm.get_next_status(l_fsm, 'ADVANCE')).to_be_null;
  end ambiguous_next_status;

  procedure retry_succeeds as
    l_fsm fsm_ut_type;
    l_status varchar2(30);
    l_validity number;
    l_retry_event varchar2(30);
  begin
    l_fsm := new_fsm('RETRY');
    fsm.retry(l_fsm, 'ADVANCE');
    select fsm_fst_id, fsm_validity, fsm_fev_id
      into l_status, l_validity, l_retry_event
      from fsm_objects where fsm_id = l_fsm.fsm_id;
    ut.expect(l_status).to_equal('MIDDLE');
    ut.expect(l_validity).to_equal(fsm.C_OK);
    ut.expect(l_retry_event).to_be_null;
  end retry_succeeds;

  procedure retry_exhausted as
    l_fsm fsm_ut_type;
    l_status varchar2(30);
  begin
    l_fsm := new_fsm('RETRY');
    update fsm_objects set fsm_validity = 2 where fsm_id = l_fsm.fsm_id;
    commit;
    fsm.retry(l_fsm, 'ADVANCE');
    select fsm_fst_id into l_status from fsm_objects where fsm_id = l_fsm.fsm_id;
    ut.expect(l_status).to_equal('ERROR');
  end retry_exhausted;

  procedure hard_fallback as
    l_fsm fsm_ut_type;
    l_status varchar2(30);
    l_validity number;
    l_events varchar2(500);
  begin
    l_fsm := new_fsm('RETRY');
    fsm_admin.merge_transition(
      p_ftr_fst_id => 'START', p_ftr_fev_id => 'AUTO', p_ftr_fcl_id => C_CLASS,
      p_ftr_fsc_id => 'RETRY', p_ftr_fst_list => 'ERROR',
      p_ftr_raise_automatically => false, p_ftr_raise_on_status => fsm.C_ERROR);
    update fsm_objects set fsm_validity = fsm.C_ERROR where fsm_id = l_fsm.fsm_id;
    commit;
    fsm.retry(l_fsm, 'ADVANCE');
    select fsm_fst_id, fsm_validity, fsm_fev_list
      into l_status, l_validity, l_events
      from fsm_objects where fsm_id = l_fsm.fsm_id;
    ut.expect(l_status).to_equal('ERROR');
    ut.expect(l_validity).to_equal(fsm.C_ERROR);
    ut.expect(l_events).to_be_null;
  end hard_fallback;

  procedure terminal_metadata_valid as
  begin
    fsm_admin.check_metadata(C_CLASS, 'RETRY');
    ut.expect(1).to_equal(1);
  end terminal_metadata_valid;

  procedure missing_initial_rejected as
    l_was_rejected boolean := false;
  begin
    update fsm_status
       set fst_initial_status = pit_util.C_FALSE
     where fst_fcl_id = C_CLASS
       and fst_id = 'START';
    commit;
    begin
      fsm_admin.check_metadata(C_CLASS, 'MASTER');
    exception
      when others then
        l_was_rejected := true;
    end;
    ut.expect(l_was_rejected).to_be_true;
  end missing_initial_rejected;
end fsm_core_test;
/
