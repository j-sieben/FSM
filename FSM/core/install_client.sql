alter session set current_schema=&INSTALL_USER.;

define tool_dir=tools/

@&tool_dir.grant_access_with_grant_option.sql "execute, under" fsm_type
@&tool_dir.grant_access.sql execute fsm_pkg
@&tool_dir.grant_access.sql execute fsm_fev
@&tool_dir.grant_access.sql execute fsm_fst
@&tool_dir.grant_access.sql execute fsm_admin_pkg

-- Tables
@&tool_dir.grant_access_with_grant_option.sql read fsm_log
@&tool_dir.grant_access_with_grant_option.sql read fsm_transitions
@&tool_dir.grant_access_with_grant_option.sql "select, references" fsm_objects

-- Views
@&tool_dir.grant_access_with_grant_option.sql select fsm_objects_v
@&tool_dir.grant_access_with_grant_option.sql select fsm_events_v
@&tool_dir.grant_access_with_grant_option.sql read fsm_status_v

-- Sequence
@&tool_dir.grant_access.sql select fsm_seq
