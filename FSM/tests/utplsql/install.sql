whenever sqlerror exit failure rollback

create table fsm_ut_trace(
  trace_id number generated always as identity,
  fsm_id number,
  trace_event varchar2(30 char) not null,
  constraint pk_fsm_ut_trace primary key (trace_id));

create or replace type fsm_ut_type under fsm_type(
  overriding member function raise_event(
    self in out nocopy fsm_ut_type,
    p_fev_id in varchar2,
    p_msg in varchar2 default null,
    p_msg_args in msg_args default null)
    return number,
  overriding member procedure leave_status(self in out nocopy fsm_ut_type),
  overriding member procedure before_transition(self in out nocopy fsm_ut_type),
  overriding member procedure persist_state(self in out nocopy fsm_ut_type),
  overriding member procedure enter_status(self in out nocopy fsm_ut_type),
  overriding member procedure after_transition(self in out nocopy fsm_ut_type),
  overriding member procedure finalize(self in out nocopy fsm_ut_type));
/

create or replace type body fsm_ut_type as
  overriding member function raise_event(
    self in out nocopy fsm_ut_type,
    p_fev_id in varchar2,
    p_msg in varchar2 default null,
    p_msg_args in msg_args default null)
    return number
  as
    l_result number;
  begin
    l_result := fsm.raise_event(self, p_fev_id, p_msg, p_msg_args);
    if l_result = fsm.C_OK then
      l_result := self.set_status(fsm.get_next_status(self, p_fev_id));
    end if;
    return l_result;
  end raise_event;

  overriding member procedure leave_status(self in out nocopy fsm_ut_type) as
  begin
    insert into fsm_ut_trace(fsm_id, trace_event) values(self.fsm_id, 'LEAVE');
  end leave_status;

  overriding member procedure before_transition(self in out nocopy fsm_ut_type) as
  begin
    insert into fsm_ut_trace(fsm_id, trace_event) values(self.fsm_id, 'BEFORE');
  end before_transition;

  overriding member procedure persist_state(self in out nocopy fsm_ut_type) as
  begin
    insert into fsm_ut_trace(fsm_id, trace_event) values(self.fsm_id, 'PERSIST');
  end persist_state;

  overriding member procedure enter_status(self in out nocopy fsm_ut_type) as
  begin
    insert into fsm_ut_trace(fsm_id, trace_event) values(self.fsm_id, 'ENTER');
  end enter_status;

  overriding member procedure after_transition(self in out nocopy fsm_ut_type) as
  begin
    insert into fsm_ut_trace(fsm_id, trace_event) values(self.fsm_id, 'AFTER');
  end after_transition;

  overriding member procedure finalize(self in out nocopy fsm_ut_type) as
  begin
    insert into fsm_ut_trace(fsm_id, trace_event) values(self.fsm_id, 'FINALIZE');
  end finalize;
end;
/

@@fsm_core_test.pks
@@fsm_core_test.pkb
