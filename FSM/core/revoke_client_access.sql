define tool_dir=tools/

@&tool_dir.revoke_access.sql "execute, under" fsm_type
@&tool_dir.revoke_access.sql execute fsm_pkg
@&tool_dir.revoke_access.sql execute fsm_fev
@&tool_dir.revoke_access.sql execute fsm_fst
@&tool_dir.revoke_access.sql execute fsm_admin_pkg

-- Tables
@&tool_dir.revoke_access.sql references fsm_objects

-- Views
@&tool_dir.revoke_access.sql read fsm_classes_v
@&tool_dir.revoke_access.sql read fsm_events_v
@&tool_dir.revoke_access.sql read fsm_log_v
@&tool_dir.revoke_access.sql read fsm_objects_v
@&tool_dir.revoke_access.sql read fsm_status_groups_v
@&tool_dir.revoke_access.sql read fsm_status_severities_v
@&tool_dir.revoke_access.sql read fsm_status_v
@&tool_dir.revoke_access.sql read fsm_transitions_v
