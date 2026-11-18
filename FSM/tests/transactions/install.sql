whenever sqlerror exit failure rollback

create table fsm_tx_trace(marker varchar2(100 char));

create or replace package fsm_tx_probe as
  fail_in_status boolean := false;
  refresh_count number := 0;
  function visible_status(p_id number) return varchar2;
  function available_for_lock(p_id number) return boolean;
end;
/
create or replace package body fsm_tx_probe as
  function visible_status(p_id number) return varchar2 as
    pragma autonomous_transaction;
    l_status varchar2(128);
  begin
    select max(fsm_fst_id) into l_status from fsm_objects where fsm_id = p_id;
    rollback;
    return l_status;
  end;
  function available_for_lock(p_id number) return boolean as
    pragma autonomous_transaction;
    l_id number;
    resource_busy exception;
    pragma exception_init(resource_busy, -54);
  begin
    select fsm_id into l_id from fsm_objects where fsm_id = p_id for update nowait;
    rollback;
    return true;
  exception when resource_busy then
    rollback;
    return false;
  end;
end;
/

create or replace type fsm_tx_type under fsm_type(
  overriding member function raise_event(
    self in out nocopy fsm_tx_type, p_fev_id in varchar2,
    p_msg in varchar2 default null, p_msg_args in msg_args default null) return number,
  overriding member procedure refresh_state(self in out nocopy fsm_tx_type),
  overriding member procedure after_transition(self in out nocopy fsm_tx_type));
/
create or replace type body fsm_tx_type as
  overriding member function raise_event(
    self in out nocopy fsm_tx_type, p_fev_id in varchar2,
    p_msg in varchar2 default null, p_msg_args in msg_args default null) return number
  as
    l_result number;
  begin
    l_result := fsm.raise_event(self, p_fev_id, p_msg, p_msg_args);
    l_result := self.set_status(fsm.get_next_status(self, p_fev_id));

    return l_result;
  end;
  overriding member procedure refresh_state(self in out nocopy fsm_tx_type) as
  begin
    fsm_tx_probe.refresh_count := fsm_tx_probe.refresh_count + 1;
  end;
  overriding member procedure after_transition(self in out nocopy fsm_tx_type) as
  begin
    if fsm_tx_probe.fail_in_status and self.fsm_fst_id != 'START' then
      raise_application_error(-20080, 'Injected failure inside SET_STATUS');
    end if;
  end;
end;
/

begin
  fsm_admin.merge_class('FTX', 'FSM_TX_TYPE', 'Transaction tests', 'Disposable transaction fixtures');
  fsm_admin.merge_sub_class('AUTO', 'FTX', 'Auto', 'Automatic chain');
  fsm_admin.merge_status_group('FLOW', 'FTX', 'Flow', 'Transaction fixtures');
  fsm_admin.merge_status(
    p_fst_id => 'START', p_fst_fcl_id => 'FTX', p_fst_fsg_id => 'FLOW',
    p_fst_name => 'Start', p_fst_description => 'Initial state', p_fst_msg_id => 'FTX_START',
    p_fst_severity => fsm.C_STORY_STEP, p_fst_initial_status => true,
    p_fst_retries_on_error => 2, p_fst_retry_time => 0);
  fsm_admin.merge_status(
    p_fst_id => 'MIDDLE', p_fst_fcl_id => 'FTX', p_fst_fsg_id => 'FLOW',
    p_fst_name => 'Middle', p_fst_description => 'Intermediate state', p_fst_msg_id => 'FTX_MIDDLE', p_fst_severity => fsm.C_STORY_STEP);
  fsm_admin.merge_status(
    p_fst_id => 'DONE', p_fst_fcl_id => 'FTX', p_fst_fsg_id => 'FLOW',
    p_fst_name => 'Done', p_fst_description => 'Terminal state', p_fst_msg_id => 'FTX_DONE',
    p_fst_severity => fsm.C_STORY_TERMINAL, p_fst_terminal_status => true);
  fsm_admin.merge_status(
    p_fst_id => 'ERROR', p_fst_fcl_id => 'FTX', p_fst_fsg_id => 'FLOW',
    p_fst_name => 'Error', p_fst_description => 'Modeled terminal business error',
    p_fst_msg_id => 'FTX_ERROR', p_fst_severity => fsm.C_STORY_ERROR,
    p_fst_terminal_status => true);
  fsm_admin.merge_event('ADVANCE', 'FTX', 'Advance', 'Advance', 'FTX_ADVANCE');
  fsm_admin.merge_event('START_ONLY', 'FTX', 'Start only', 'Start only', 'FTX_START_ONLY');
  fsm_admin.merge_event('FINISH', 'FTX', 'Finish', 'Finish', 'FTX_FINISH');
  fsm_admin.merge_event('AUTO', 'FTX', 'Automatic', 'Automatic', 'FTX_AUTO');
  fsm_admin.merge_transition('START', 'ADVANCE', 'FTX', 'MASTER', 'MIDDLE', false);
  fsm_admin.merge_transition('START', 'START_ONLY', 'FTX', 'MASTER', 'MIDDLE', false);
  fsm_admin.merge_transition('MIDDLE', 'ADVANCE', 'FTX', 'MASTER', 'DONE', false);
  fsm_admin.merge_transition('MIDDLE', 'FINISH', 'FTX', 'MASTER', 'DONE', false);
  fsm_admin.merge_transition('START', 'AUTO', 'FTX', 'AUTO', 'MIDDLE', true);
  fsm_admin.merge_transition('MIDDLE', 'AUTO', 'FTX', 'AUTO', 'DONE', true);
  commit;
end;
/
