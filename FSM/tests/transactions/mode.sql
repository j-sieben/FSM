-- Dedicated quiet owner test session only. &1 is TRUE or FALSE.
begin
  param.set_boolean('AUTO_COMMIT', 'FSM', upper('&1.') = 'TRUE');
  commit;
  dbms_session.reset_package;
end;
/

@@../../core/scripts/ParameterGroup_FSM.sql
begin
  if param.get_boolean('AUTO_COMMIT', 'FSM') != (upper('&1.') = 'TRUE') then
    raise_application_error(-20090, 'Repeated parameter installation overwrote the configured value');
  end if;
  dbms_session.reset_package;
end;
/

declare
  l_fsm fsm_tx_type;
  l_result number;
  l_count number;
  l_rejected boolean;
  l_auto boolean := upper('&1.') = 'TRUE';
  procedure check(p_ok boolean, p_name varchar2) as
  begin
    if p_ok is null or not p_ok then raise_application_error(-20090, p_name); end if;
    dbms_output.put_line('PASS: &1. ' || p_name);
  end;
  function new_instance(p_subclass varchar2 default 'MASTER') return fsm_tx_type as
    l_new fsm_tx_type := fsm_tx_type(null, 'FTX', p_subclass, null, null, null, fsm.C_OK, null, 'N');
  begin
    fsm.initialize(l_new);
    return l_new;
  end;
begin
  l_fsm := new_instance;
  check((fsm_tx_probe.visible_status(l_fsm.fsm_id) = 'START' and l_auto)
        or (fsm_tx_probe.visible_status(l_fsm.fsm_id) is null and not l_auto), 'initialization visibility');
  commit;

  -- A stale object must be corrected before event decisions.
  l_fsm.fsm_fst_id := 'DONE';
  l_fsm.fsm_fev_list := null;
  l_result := l_fsm.raise_event('ADVANCE');
  check(l_fsm.fsm_fst_id = 'MIDDLE', 'refresh replaces stale common state');
  check(fsm_tx_probe.refresh_count > 0, 'subtype refresh hook called');
  check(fsm_tx_probe.visible_status(l_fsm.fsm_id) = case when l_auto then 'MIDDLE' else 'START' end,
        'transition commit policy');
  rollback;
  select fsm_fst_id into l_fsm.fsm_fst_id from fsm_objects where fsm_id = l_fsm.fsm_id;
  check(l_fsm.fsm_fst_id = case when l_auto then 'MIDDLE' else 'START' end, 'rollback outcome');

  l_rejected := false;
  begin
    l_result := l_fsm.set_status('DONE');
  exception when others then
    if sqlcode != -20001 then raise; end if;
    l_rejected := true;
  end;
  check(l_rejected, 'direct SET_STATUS denied after completion');

  insert into fsm_tx_trace values('uncommitted before rejection');
  l_rejected := false;
  begin
    l_result := l_fsm.raise_event('UNKNOWN');
  exception when others then
    if sqlcode != -20003 then raise; end if;
    l_rejected := true;
  end;
  check(l_rejected, 'event rejection');
  check(fsm_tx_probe.available_for_lock(l_fsm.fsm_id), 'initial rejection left no FSM row lock');
  rollback;
  select count(*) into l_count from fsm_tx_trace;
  check(l_count = 0, 'rejection did not commit caller changes');

  l_fsm := new_instance;
  commit;
  fsm_tx_probe.fail_in_status := true;
  insert into fsm_tx_trace values('uncommitted before failure');
  l_rejected := false;
  begin
    l_result := l_fsm.raise_event('ADVANCE');
  exception when others then
    if sqlcode != -20080 then raise; end if;
    l_rejected := true;
  end;
  check(l_rejected, 'original technical exception propagated');
  check(fsm_tx_probe.visible_status(l_fsm.fsm_id) = 'START', 'no commit before status completion');
  rollback;
  fsm_tx_probe.fail_in_status := false;
  select count(*) into l_count from fsm_tx_trace;
  check(l_count = 0, 'caller changes roll back with failed transition');
  l_rejected := false;
  begin l_result := l_fsm.set_status('DONE');
  exception when others then
    if sqlcode != -20001 then raise; end if;
    l_rejected := true;
  end;
  check(l_rejected, 'failure cleared event context');

  l_fsm := new_instance('AUTO');
  check(l_fsm.fsm_fst_id = 'DONE', 'automatic chain completed');
  check((fsm_tx_probe.visible_status(l_fsm.fsm_id) = 'DONE' and l_auto)
        or (fsm_tx_probe.visible_status(l_fsm.fsm_id) is null and not l_auto), 'automatic chain commit policy');
  rollback;

  -- Failure in the first nested handler must not commit initialization or a child.
  fsm_tx_probe.fail_in_status := true;
  l_rejected := false;
  l_fsm := fsm_tx_type(null, 'FTX', 'AUTO', null, null, null, fsm.C_OK, null, 'N');
  begin fsm.initialize(l_fsm);
  exception when others then
    if sqlcode != -20080 then raise; end if;
    l_rejected := true;
  end;
  check(l_rejected, 'nested automatic error propagated');
  check(fsm_tx_probe.visible_status(l_fsm.fsm_id) is null, 'no intermediate automatic commit');
  rollback;
  fsm_tx_probe.fail_in_status := false;

  -- Retry runs under an admitted context on a row already locked by the parent.
  l_fsm := new_instance;
  commit;
  l_result := fsm.raise_event(l_fsm, 'ADVANCE');
  fsm.retry(l_fsm, 'ADVANCE');

  check(l_fsm.fsm_fst_id = 'MIDDLE', 'retry under parent row lock');
  check(fsm_tx_probe.visible_status(l_fsm.fsm_id) = case when l_auto then 'MIDDLE' else 'START' end,
        'retry shares transaction policy');
  rollback;
  -- Exhausted business retry without an error route uses the ordinary fallback,
  -- including when the parent already owns the row lock.
  l_fsm := new_instance;
  commit;
  update fsm_objects set fsm_validity = fsm.C_ERROR where fsm_id = l_fsm.fsm_id;
  l_result := fsm.raise_event(l_fsm, 'ADVANCE');
  fsm.retry(l_fsm, 'ADVANCE');

  check(l_fsm.fsm_fst_id = 'ERROR', 'business error fallback under parent row lock');
  check(fsm_tx_probe.visible_status(l_fsm.fsm_id) = case when l_auto then 'ERROR' else 'START' end,
        'error fallback shares transaction policy');
  rollback;

  -- A parameter update must not change the already initialized package policy.
  param.set_boolean('AUTO_COMMIT', 'FSM', not l_auto);
  commit;
  l_fsm := new_instance;
  check((fsm_tx_probe.visible_status(l_fsm.fsm_id) = 'START' and l_auto)
        or (fsm_tx_probe.visible_status(l_fsm.fsm_id) is null and not l_auto), 'commit policy cached for package lifetime');
  rollback;
  param.set_boolean('AUTO_COMMIT', 'FSM', l_auto);
  commit;
exception when others then
  rollback;
  raise;
end;
/
