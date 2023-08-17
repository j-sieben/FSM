prompt &h2.Granting access to business data objects to %REMOTE_USER.


prompt &h3.Grant access to views
@&tool_dir.grant_access_with_grant_option read demo_users_vw
@&tool_dir.grant_access_with_grant_option read fsm_requests_vw
@&tool_dir.grant_access_with_grant_option read fsm_requestors_vw
@&tool_dir.grant_access_with_grant_option read fsm_request_types_vw

prompt &h3.Grant access to packages
@&tool_dir.grant_access execute bl_request
@&tool_dir.grant_access execute fsm_req_type
@&tool_dir.grant_access execute fsm_req