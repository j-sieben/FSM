define tool_dir=tools/

@&tool_dir.create_synonym.sql fsm_type
@&tool_dir.create_synonym.sql fsm
@&tool_dir.create_synonym.sql fsm_fev
@&tool_dir.create_synonym.sql fsm_fst
@&tool_dir.create_synonym.sql fsm_admin

-- Tables
@&tool_dir.create_synonym.sql fsm_objects

-- Views
@&tool_dir.create_synonym.sql fsm_classes_v
@&tool_dir.create_synonym.sql fsm_sub_classes_v
@&tool_dir.create_synonym.sql fsm_events_v
@&tool_dir.create_synonym.sql fsm_log_v
@&tool_dir.create_synonym.sql fsm_objects_v
@&tool_dir.create_synonym.sql fsm_status_groups_v
@&tool_dir.create_synonym.sql fsm_status_severities_v
@&tool_dir.create_synonym.sql fsm_status_v
@&tool_dir.create_synonym.sql fsm_transitions_v
@&tool_dir.create_synonym.sql bl_fsm_next_commands

define view_dir=core/views/
