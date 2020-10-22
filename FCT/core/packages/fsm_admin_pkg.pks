create or replace package &TOOLKIT._admin_pkg
  -- Für Leserecht auf USER_IDENTIFIERS
  authid current_user 
as
  /* SETTER */
  procedure merge_class(
    p_fcl_id in &TOOLKIT._class.fcl_id%type,
    p_fcl_name in &TOOLKIT._class.fcl_name%type,
    p_fcl_description in &TOOLKIT._class.fcl_description%type,
    p_fcl_active in boolean default true);
    
    
  procedure merge_event(
    p_fev_id in &TOOLKIT._event.fev_id%type,
    p_fev_fcl_id in &TOOLKIT._event.fev_fcl_id%type,
    p_fev_msg_id in &TOOLKIT._event.fev_msg_id%type,
    p_fev_name in &TOOLKIT._event.fev_name%type,
    p_fev_description in &TOOLKIT._event.fev_description%type,
    p_fev_active in boolean default true,
    p_fev_command in &TOOLKIT._event.fev_command%type default null,
    p_fev_raised_by_user in boolean default false,
    p_fev_button_icon in &TOOLKIT._event.fev_button_icon%type default null,
    p_fev_button_highlight in boolean default false,
    p_fev_confirm_message in &TOOLKIT._event.fev_confirm_message%type default null);
    
    
  procedure merge_status(
    p_fst_id in &TOOLKIT._status.fst_id%type,
    p_fst_fcl_id in &TOOLKIT._status.fst_fcl_id%type,
    p_fst_fsg_id in &TOOLKIT._status.fst_fsg_id%type,
    p_fst_msg_id in &TOOLKIT._status.fst_msg_id%type,
    p_fst_name in &TOOLKIT._status.fst_name%type,
    p_fst_description in &TOOLKIT._status.fst_description%type,
    p_fst_active in boolean default true,
    p_fst_retries_on_error in &TOOLKIT._status.fst_retries_on_error%type default 0,
    p_fst_retry_schedule in &TOOLKIT._status.fst_retry_schedule%type default null,
    p_fst_retry_time in &TOOLKIT._status.fst_retry_time%type default null,
    p_fst_icon_css in &TOOLKIT._status.fst_icon_css%type default null,
    p_fst_name_css in &TOOLKIT._status.fst_name_css%type default null);
    
    
  procedure merge_status_group(
    p_fsg_id in &TOOLKIT._status_group.fsg_id%type,
    p_fsg_name in &TOOLKIT._status_group.fsg_name%type,
    p_fsg_description in &TOOLKIT._status_group.fsg_description%type,
    p_fsg_icon_css in &TOOLKIT._status_group.fsg_icon_css%type,
    p_fsg_name_css in &TOOLKIT._status_group.fsg_name_css%type,
    p_fst_active in boolean default true);
    
    
 procedure  merge_transition(
    p_ftr_fst_id in varchar2,
    p_ftr_fev_id in varchar2,
    p_ftr_fcl_id in varchar2,
    p_ftr_fst_list in varchar2,
    p_ftr_active in boolean default true,
    p_ftr_raise_automatically in boolean,
    p_ftr_raise_on_status in number default 0,
    p_ftr_required_role in varchar2 default null);
  
  /* Prozedur zur Erstellung eines Konstantenpackages für alle Events */
  procedure create_event_package;
    
  /* Prozedur zur Erstellung eines Konstantenpackages für alle Status */
  procedure create_status_package;
end &TOOLKIT._admin_pkg;
/

