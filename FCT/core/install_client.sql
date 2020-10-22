alter session set current_schema=&INSTALL_USER.;

define tool_dir=tools/

@&tool_dir.grant_access_with_grant_option.sql "execute, under" &TOOLKIT._type
@&tool_dir.grant_access.sql execute &TOOLKIT._pkg
@&tool_dir.grant_access.sql execute &TOOLKIT._fev
@&tool_dir.grant_access.sql execute &TOOLKIT._fst
@&tool_dir.grant_access.sql execute &TOOLKIT._admin_pkg

-- Tables
@&tool_dir.grant_access_with_grant_option.sql read &TOOLKIT._log
@&tool_dir.grant_access_with_grant_option.sql read &TOOLKIT._event
@&tool_dir.grant_access_with_grant_option.sql read &TOOLKIT._status
@&tool_dir.grant_access_with_grant_option.sql read &TOOLKIT._transition
@&tool_dir.grant_access_with_grant_option.sql "select, references" &TOOLKIT._object

-- Views
@&tool_dir.grant_access_with_grant_option.sql read &TOOLKIT._object_vw

-- Sequence
@&tool_dir.grant_access.sql select &TOOLKIT._seq
