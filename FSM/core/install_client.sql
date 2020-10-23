alter session set current_schema=&INSTALL_USER.;

define tool_dir=tools/

@&tool_dir.grant_access_with_grant_option.sql "execute, under" fsm_type
@&tool_dir.grant_access.sql execute fsm_pkg
@&tool_dir.grant_access.sql execute fsm_fev
@&tool_dir.grant_access.sql execute fsm_fst
@&tool_dir.grant_access.sql execute fsm_admin_pkg

-- Tables
@&tool_dir.grant_access_with_grant_option.sql read fsm_log
@&tool_dir.grant_access_with_grant_option.sql read fsm_event
@&tool_dir.grant_access_with_grant_option.sql read fsm_status
@&tool_dir.grant_access_with_grant_option.sql read fsm_transition
@&tool_dir.grant_access_with_grant_option.sql "select, references" fsm_object

-- Views
@&tool_dir.grant_access_with_grant_option.sql select fsm_object_vw

-- Sequence
@&tool_dir.grant_access.sql select fsm_seq
