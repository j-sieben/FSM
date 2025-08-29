@tools/set_folders core

prompt &h2.Create Default Messages
--@&tools.run_language_script create_messages
--@&tools.run_language_script TranslatableItemsGroup_FSM

prompt &h2.Create Sequences
@&tools.check_has_sequence fsm_seq
@&tools.check_has_sequence fsm_log_seq

prompt &h2.Create Tables
@&tools.check_has_table fsm_classes
@&tools.check_has_table fsm_sub_classes
@&tools.check_has_table fsm_status_groups
@&tools.check_has_table fsm_events
@&tools.check_has_table fsm_status
@&tools.check_has_table fsm_transitions
@&tools.check_has_table fsm_objects
@&tools.check_has_table fsm_log
@&tools.check_has_table fsm_status_severities

prompt &h2.Create Views
@&tools.install_view fsm_classes_v
@&tools.install_view fsm_sub_classes_v
@&tools.install_view fsm_status_groups_v
@&tools.install_view fsm_status_severities_v
@&tools.install_view fsm_events_v
@&tools.install_view fsm_status_v
@&tools.install_view fsm_transitions_v
@&tools.install_view fsm_objects_v
@&tools.install_view fsm_log_v
@&tools.install_view fsm_fsl_log_v
@&tools.install_view bl_fsm_active_status_event
@&tools.install_view bl_fsm_hierarchy
@&tools.install_view bl_fsm_next_commands

prompt &h2.Create Types and Packages
prompt &h3.Specifications
@&tools.install_type_spec fsm_type
@&tools.install_package_spec fsm
@&tools.install_package_spec fsm_admin

prompt &h3.Bodies
@&tools.install_type_body fsm_type
@&tools.install_package_body fsm_admin

prompt &h2.Load Initial Data
@&tools.run_script initial_data
@&tools.run_script utl_text_templates_FSM

prompt &h2.Create Event and Status Packages
begin
  fsm_admin.create_event_package;
  fsm_admin.create_status_package;
end;
/

@&tools.install_package_body fsm