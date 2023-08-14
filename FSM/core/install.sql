@tools/set_folders core

prompt - creating default messages
@&tools.run_language_script create_messages
@&tools.run_language_script TranslatableItemsGroup_FSM

prompt - create tables
@&tools.check_has_table fsm_classes
@&tools.check_has_table fsm_status_groups
@&tools.check_has_table fsm_events
@&tools.check_has_table fsm_status
@&tools.check_has_table fsm_transitions
@&tools.check_has_table fsm_objects
@&tools.check_has_table fsm_log
@&tools.check_has_table fsm_status_severities

prompt - create views
@&tools.install_view fsm_classes_v
@&tools.install_view fsm_status_groups_v
@&tools.install_view fsm_status_severities_v
@&tools.install_view fsm_events_v
@&tools.install_view fsm_status_v
@&tools.install_view fsm_transitions_v
@&tools.install_view fsm_objects_v
@&tools.install_view fsm_log_v
@&tools.install_view fsm_fsl_log_v
@&tools.install_view bl_fsm_active_status_event

prompt - sequences
@&tools.check_has_sequence fsm_seq
@&tools.check_has_sequence fsm_log_seq

prompt - create types and packages
@&tools.install_type_spec fsm_type
@&tools.install_package_spec fsm
@&tools.install_package_spec fsm_admin

@&tools.install_type_body fsm_type
@&tools.install_package_body fsm_admin

prompt . - load initial data
@&tools.run_script initial_data

prompt . - create event and status packages
begin
  fsm_admin.create_event_package;
  fsm_admin.create_status_package;
end;
/

@&tools.run_script ParameterGroup_PIT

@&tools.install_package_body fsm