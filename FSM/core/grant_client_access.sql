define tool_dir=tools/

@&tool_dir.grant_access_with_grant_option.sql "execute, under" fsm_type
@&tool_dir.grant_access.sql execute fsm
@&tool_dir.grant_access.sql execute fsm_fev
@&tool_dir.grant_access.sql execute fsm_fst
@&tool_dir.grant_access.sql execute fsm_admin

-- Tables
@&tool_dir.grant_access_with_grant_option.sql references fsm_objects

-- Views
@&tool_dir.grant_access_with_grant_option.sql read fsm_classes_v
@&tool_dir.grant_access_with_grant_option.sql read fsm_events_v
@&tool_dir.grant_access_with_grant_option.sql read fsm_log_v
@&tool_dir.grant_access_with_grant_option.sql read fsm_objects_v
@&tool_dir.grant_access_with_grant_option.sql read fsm_status_groups_v
@&tool_dir.grant_access_with_grant_option.sql read fsm_status_severities_v
@&tool_dir.grant_access_with_grant_option.sql read fsm_status_v
@&tool_dir.grant_access_with_grant_option.sql read fsm_transitions_v
@&tool_dir.grant_access_with_grant_option.sql read bl_fsm_active_status_event
@&tool_dir.grant_access_with_grant_option.sql read bl_fsm_hierarchy
@&tool_dir.grant_access_with_grant_option.sql read bl_fsm_next_commands
