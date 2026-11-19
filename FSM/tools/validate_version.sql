-- Run before DDL. Supported starters validate these values before SQL*Plus.
-- Direct SQL callers must supply trusted version/commit arguments as well.
set define on
whenever oserror exit failure rollback
whenever sqlerror exit failure rollback

declare
  l_version varchar2(32767) := '&FSM_VERSION.';
  l_commit varchar2(32767) := '&FSM_GIT_COMMIT.';
begin
  if l_version is null or length(l_version) > 40 or
     not regexp_like(l_version, '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.[1-9][0-9]*$', 'c') then
    raise_application_error(-20000, 'Invalid FSM version: expected Major.Minor.CommitCount');
  end if;
  if l_commit is null or not regexp_like(l_commit, '^([0-9a-f]{40}|[0-9a-f]{64})$', 'c') then
    raise_application_error(-20000, 'Invalid FSM Git commit: expected full lowercase hash');
  end if;
end;
/
