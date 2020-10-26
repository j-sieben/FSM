alter session set current_schema=&INSTALL_USER.;

-- Packages
@&tool_dir.revoke_access.sql all fsm_type
@&tool_dir.revoke_access.sql all fsm_pkg
@&tool_dir.revoke_access.sql all fsm_fev
@&tool_dir.revoke_access.sql all fsm_fst
@&tool_dir.revoke_access.sql all fsm_admin_pkg

-- Tables
@&tool_dir.revoke_access.sql all fsm_log
@&tool_dir.revoke_access.sql all fsm_status
@&tool_dir.revoke_access.sql all fsm_transitions
@&tool_dir.revoke_access.sql all fsm_objects

-- Views
@&tool_dir.revoke_access.sql all fsm_objects_v
@&tool_dir.revoke_access.sql all fsm_events_v

-- Sequence
@&tool_dir.revoke_access.sql select fsm_seq
