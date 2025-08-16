create or replace package body fsm_admin
as
  
  C_STD_FCL constant pit_util.ora_name_type := 'FSM';
  C_FCL constant pit_util.ora_name_type := '#FCL#';
  C_PTI_CLASS_PREFIX pit_util.ora_name_type := 'FCL_';
  C_PTI_SUB_CLASS_PREFIX pit_util.ora_name_type := 'FSC_';
  C_PTI_GROUP_PREFIX pit_util.ora_name_type := 'FSG_#FCL#_';
  C_PTI_SEVERITY_PREFIX pit_util.ora_name_type := 'FSS_#FCL#_';
  C_PTI_STATUS_PREFIX pit_util.ora_name_type := 'FST_#FCL#_';
  C_PTI_EVENT_PREFIX pit_util.ora_name_type := 'FEV_#FCL#_';
  C_SUB_CLASS_MASTER pit_util.ora_name_type := 'MASTER';
  
  
  /* Helper */
  function bool_to_char(
    p_bool in boolean)
    return varchar2
  as
  begin
    return case when p_bool then pit_util.C_TRUE else pit_util.C_FALSE end;
  end bool_to_char;
  
  
  /**
    Procedure: create_sub_class
      Method to create a default entry for a new class entry. This default entry is
      named MASTER and is used if no sub classes are used.
      
    Parameter:
      p_fcl_id - ID of the class to create a sub class for
   */
  procedure create_sub_class(
    p_fcl_id in fsm_classes.fcl_id%type)
  as
    l_has_sub_class binary_integer;
  begin
  
    select count(*)
      into l_has_sub_class
      from dual
     where exists(
           select null
             from fsm_sub_classes
            where fsc_id = C_SUB_CLASS_MASTER
              and fsc_fcl_id = p_fcl_id);
              
    if l_has_sub_class = 0 then
      merge_sub_class(
        p_fsc_id => C_SUB_CLASS_MASTER,
        p_fsc_fcl_id => p_fcl_id,
        p_fsc_name => 'Master',
        p_fsc_description => 'Default sub class',
        p_fsc_active => true);
    end if;
    
  end create_sub_class;
    
  
  /* INTERFACE */    
  /**
    Procedure: merge_class
      See <FSM_ADMIN.merge_class>
   */
  procedure merge_class(
    p_fcl_id in fsm_classes_v.fcl_id%type,
    p_fcl_name in fsm_classes_v.fcl_name%type,
    p_fcl_description in fsm_classes_v.fcl_description%type,
    p_fcl_active in boolean default true)
  as
    l_active pit_util.flag_type;
    l_pti_id pit_util.ora_name_type;
  begin
    l_active := bool_to_char(p_fcl_active);
    l_pti_id := C_PTI_CLASS_PREFIX || p_fcl_id;
    
    pit_admin.merge_message_group(
      p_pmg_name => p_fcl_id);
    
    pit_admin.merge_translatable_item(
      p_pti_id => l_pti_id,
      p_pti_pml_name => pit.get_default_language,
      p_pti_pmg_name => p_fcl_id,
      p_pti_name => p_fcl_name,
      p_pti_description => p_fcl_description);
    
    merge into fsm_classes t
    using (select p_fcl_id fcl_id,
                  l_pti_id fcl_pti_id,
                  l_active fcl_active
             from dual) s
       on (t.fcl_id = s.fcl_id)
     when matched then update set
          fcl_active = s.fcl_active
     when not matched then insert (fcl_id, fcl_pti_id, fcl_active)
          values (s.fcl_id, s.fcl_pti_id, s.fcl_active);
          
    create_sub_class(p_fcl_id);
          
  end merge_class;
  
  procedure merge_class(
    p_row in fsm_classes_v%rowtype)
  as
  begin
    merge_class(
      p_fcl_id => p_row.fcl_id,
      p_fcl_name => p_row.fcl_name,
      p_fcl_description => p_row.fcl_description,
      p_fcl_active => pit_util.to_bool(p_row.fcl_active));
  end merge_class;
  
  
  /**
    Procedure: delete_class
      See <FSM_ADMIN.delete_class>
   */
  procedure delete_class(
    p_fcl_id in fsm_classes_v.fcl_id%type,
    p_force in boolean default false)
  as
    l_pti_id pit_util.ora_name_type;
  begin
    l_pti_id := C_PTI_CLASS_PREFIX || p_fcl_id;
    
    if p_force then
      delete from fsm_objects
       where fsm_fst_id in (
             select fst_id
               from fsm_status
              where fst_fcl_id = p_fcl_id);
              
      delete from fsm_transitions
       where ftr_fcl_id = p_fcl_id;
      
      delete from fsm_status
       where fst_fcl_id = p_fcl_id;
       
      delete from fsm_events
       where fev_fcl_id = p_fcl_id;
       
      delete from fsm_sub_classes
       where fsc_fcl_id = p_fcl_id;
    end if;
    
    delete from fsm_classes
     where fcl_id = p_fcl_id;
    
    pit_admin.delete_translatable_item(
      p_pti_id => l_pti_id,
      p_pti_pmg_name => p_fcl_id);
  end delete_class;  
    
  
  /** 
    Procedure: merge_sub_class
      See <FSM_ADMIN.merge_sub_class>
   */
  procedure merge_sub_class(
    p_fsc_id in fsm_sub_classes_v.fsc_id%type,
    p_fsc_fcl_id in fsm_sub_classes_v.fsc_fcl_id%type,
    p_fsc_name in fsm_sub_classes_v.fsc_name%type,
    p_fsc_description in fsm_sub_classes_v.fsc_description%type,
    p_fsc_active in boolean default true)
  as
    l_active pit_util.flag_type;
    l_pti_id pit_util.ora_name_type;
  begin
    l_active := bool_to_char(p_fsc_active);
    l_pti_id := C_PTI_SUB_CLASS_PREFIX || p_fsc_id;
    
    pit_admin.merge_message_group(
      p_pmg_name => p_fsc_fcl_id);
    
    pit_admin.merge_translatable_item(
      p_pti_id => l_pti_id,
      p_pti_pml_name => pit.get_default_language,
      p_pti_pmg_name => p_fsc_fcl_id,
      p_pti_name => p_fsc_name,
      p_pti_description => p_fsc_description);
    
    merge into fsm_sub_classes t
    using (select p_fsc_id fsc_id,
                  p_fsc_fcl_id fsc_fcl_id,
                  l_pti_id fsc_pti_id,
                  l_active fsc_active
             from dual) s
       on (t.fsc_id = s.fsc_id
       and t.fsc_fcl_id = s.fsc_fcl_id)
     when matched then update set
          fsc_active = s.fsc_active
     when not matched then insert (fsc_id, fsc_fcl_id, fsc_pti_id, fsc_active)
          values (s.fsc_id, s.fsc_fcl_id, s.fsc_pti_id, s.fsc_active);
          
  end merge_sub_class;
    
  
  /** 
    Procedure: merge_sub_class
      See <FSM_ADMIN.merge_sub_class>
   */
  procedure merge_sub_class(
    p_row fsm_sub_classes_v%rowtype)
  as
  begin
    merge_sub_class(
      p_fsc_id => p_row.fsc_id,
      p_fsc_fcl_id => p_row.fsc_fcl_id,
      p_fsc_name => p_row.fsc_name,
      p_fsc_description => p_row.fsc_description,
      p_fsc_active => pit_util.to_bool(p_row.fsc_active));
  end merge_sub_class;
    
  
  /** 
    Procedure: delete_sub_class
      See <FSM_ADMIN.delete_sub_class>
   */
  procedure delete_sub_class(
    p_fsc_id in fsm_sub_classes_v.fsc_id%type,
    p_fsc_fcl_id in fsm_sub_classes_v.fsc_fcl_id%type,
    p_force in boolean default false)
  as
    l_pti_id pit_util.ora_name_type;
  begin
    l_pti_id := C_PTI_CLASS_PREFIX || p_fsc_id;
    
    if p_force then
      delete from fsm_transitions
       where ftr_fcl_id = p_fsc_fcl_id
         and ftr_fsc_id = p_fsc_id;
    end if;
    
    delete from fsm_sub_classes
     where fsc_id = p_fsc_id;
    
    pit_admin.delete_translatable_item(
      p_pti_id => l_pti_id,
      p_pti_pmg_name => p_fsc_id);
      
  end delete_sub_class;  
       
  
  /**
    Procedure: merge_status_group
      See <FSM_ADMIN.merge_status_group>
   */
  procedure merge_status_group(
    p_fsg_id in fsm_status_groups_v.fsg_id%type,
    p_fsg_fcl_id in fsm_status_groups_v.fsg_fcl_id%type,
    p_fsg_name in fsm_status_groups_v.fsg_name%type,
    p_fsg_description in fsm_status_groups_v.fsg_description%type,
    p_fsg_icon_css in fsm_status_groups_v.fsg_icon_css%type default null,
    p_fsg_name_css in fsm_status_groups_v.fsg_name_css%type default null,
    p_fsg_active in boolean default true)
  as
    l_active pit_util.flag_type;
    l_pti_id pit_util.ora_name_type;
  begin
    l_active := bool_to_char(p_fsg_active);
    l_pti_id := replace(C_PTI_GROUP_PREFIX, C_FCL, p_fsg_fcl_id) || p_fsg_id;
    
    pit_admin.merge_translatable_item(
      p_pti_id => l_pti_id,
      p_pti_pml_name => pit.get_default_language,
      p_pti_pmg_name => p_fsg_fcl_id,
      p_pti_name => p_fsg_name,
      p_pti_description => p_fsg_description);
      
    merge into fsm_status_groups t
    using (select p_fsg_id fsg_id,
                  p_fsg_fcl_id fsg_fcl_id,
                  l_pti_id fsg_pti_id,
                  p_fsg_icon_css fsg_icon_css,
                  p_fsg_name_css fsg_name_css,
                  l_active fsg_active
             from dual) s
       on (t.fsg_id = s.fsg_id
       and t.fsg_fcl_id = s.fsg_fcl_id)
     when matched then update set
          t.fsg_icon_css = s.fsg_icon_css,
          t.fsg_name_css = s.fsg_name_css,
          t.fsg_active = s.fsg_active
     when not matched then insert(fsg_id, fsg_fcl_id, fsg_pti_id, fsg_icon_css, fsg_name_css, fsg_active)
          values(s.fsg_id, s.fsg_fcl_id, s.fsg_pti_id, s.fsg_icon_css, s.fsg_name_css, s.fsg_active);
  end merge_status_group;
  
  procedure merge_status_group(
    p_row in fsm_status_groups_v%rowtype)
  as
  begin
    merge_status_group(
      p_fsg_id => p_row.fsg_id,
      p_fsg_fcl_id => p_row.fsg_fcl_id,
      p_fsg_name => p_row.fsg_name,
      p_fsg_description => p_row.fsg_description,
      p_fsg_icon_css => p_row.fsg_icon_css,
      p_fsg_name_css => p_row.fsg_name_css,
      p_fsg_active => pit_util.to_bool(p_row.fsg_active));
  end merge_status_group;
  
  
  /**
    Procedure: delete_status_group
      See <FSM_ADMIN.delete_status_group>
   */
  procedure delete_status_group(
    p_fsg_id in fsm_status_groups_v.fsg_id%type,
    p_fsg_fcl_id in fsm_status_groups_v.fsg_fcl_id%type,
    p_force in boolean default false)
  as
    l_pti_id pit_util.ora_name_type;
  begin
    l_pti_id := replace(C_PTI_GROUP_PREFIX, C_FCL, p_fsg_fcl_id) || p_fsg_id;
    
    if p_force then
      delete from fsm_transitions
       where ftr_fst_id in (
             select fst_id
               from fsm_status
              where fst_fsg_id = p_fsg_id);
      delete from fsm_status
       where fst_fsg_id = p_fsg_id
         and fst_fcl_id = p_fsg_fcl_id;
    end if;
    
    delete from fsm_status_groups
     where fsg_id = p_fsg_id
       and fsg_fcl_id = p_fsg_fcl_id;
    
    pit_admin.delete_translatable_item(
      p_pti_id => l_pti_id,
      p_pti_pmg_name => p_fsg_fcl_id);
  end delete_status_group;
    
    
  /**
    Procedure: merge_status_severity
      See <FSM_ADMIN.merge_status_severity>
   */
  procedure merge_status_severity(
    p_fss_id in fsm_status_severities_v.fss_id%type,
    p_fss_fcl_id in fsm_status_severities_v.fss_fcl_id%type,
    p_fss_name in fsm_status_severities_v.fss_name%type,
    p_fss_description in fsm_status_severities_v.fss_description%type,
    p_fss_html in fsm_status_severities_v.fss_html%type,
    p_fss_icon in fsm_status_severities_v.fss_icon%type)
  as
    l_pti_id pit_util.ora_name_type;
  begin
    l_pti_id := replace(C_PTI_SEVERITY_PREFIX, C_FCL, p_fss_fcl_id) || p_fss_id;
    
    pit_admin.merge_translatable_item(
      p_pti_id => l_pti_id,
      p_pti_pml_name => pit.get_default_language,
      p_pti_pmg_name => p_fss_fcl_id,
      p_pti_name => p_fss_name,
      p_pti_description => p_fss_description);
      
    merge into fsm_status_severities t
    using (select p_fss_id fss_id,
                  p_fss_fcl_id fss_fcl_id,
                  l_pti_id fss_pti_id,
                  p_fss_html fss_html,
                  p_fss_icon fss_icon
             from dual) s
       on (t.fss_id = s.fss_id)
     when not matched then insert(fss_id, fss_fcl_id, fss_pti_id, fss_html, fss_icon)
          values(s.fss_id, s.fss_fcl_id, s.fss_pti_id, s.fss_html, s.fss_icon);
  end merge_status_severity;
  
  procedure merge_status_severity(
    p_row in fsm_status_severities_v%rowtype)
  as
  begin
    merge_status_severity(
      p_fss_id => p_row.fss_id,
      p_fss_fcl_id => p_row.fss_fcl_id,
      p_fss_name => p_row.fss_name,
      p_fss_description => p_row.fss_description,
      p_fss_html => p_row.fss_html,
      p_fss_icon => p_row.fss_icon);
  end merge_status_severity;
  
    
  /**
    Procedure: delete_status_severity
      See <FSM_ADMIN.delete_status_severity>
   */
  procedure delete_status_severity(
    p_fss_id in fsm_status_severities_v.fss_id%type,
    p_fss_fcl_id in fsm_status_severities_v.fss_fcl_id%type)
  as
  begin
    delete from fsm_status_severities
     where fss_id = p_fss_id
       and fss_fcl_id = p_fss_fcl_id;
  end delete_status_severity;
  
    
  /**
    Procedure: merge_status
      See <FSM_ADMIN.merge_status>
   */
  procedure merge_status(
    p_fst_id in fsm_status_v.fst_id%type,
    p_fst_fcl_id in fsm_status_v.fst_fcl_id%type,
    p_fst_fsg_id in fsm_status_v.fst_fsg_id%type,
    p_fst_name in fsm_status_v.fst_name%type,
    p_fst_description in fsm_status_v.fst_description%type,
    p_fst_severity in fsm_status_v.fst_severity%type,
    p_fst_msg_id in fsm_status_v.fst_msg_id%type default msg.FSM_STATUS_CHANGED,
    p_fst_retries_on_error in fsm_status_v.fst_retries_on_error%type default 0,
    p_fst_retry_schedule in fsm_status_v.fst_retry_schedule%type default null,
    p_fst_retry_time in fsm_status_v.fst_retry_time%type default null,
    p_fst_icon_css in fsm_status_v.fst_icon_css%type default null,
    p_fst_name_css in fsm_status_v.fst_name_css%type default null,
    p_fst_active in boolean default true)
  as
    l_active pit_util.flag_type;
    l_pti_id pit_util.ora_name_type;
  begin
    l_active := bool_to_char(p_fst_active);
    l_pti_id := replace(C_PTI_STATUS_PREFIX, C_FCL, p_fst_fcl_id) || p_fst_id;
    
    pit_admin.merge_translatable_item(
      p_pti_id => l_pti_id,
      p_pti_pml_name => pit.get_default_language,
      p_pti_pmg_name => p_fst_fcl_id,
      p_pti_name => p_fst_name,
      p_pti_description => p_fst_description);
      
    -- predefine messages. Can be overwritten with "real" messages later
    if p_fst_msg_id not like 'FSM%' then
      pit_admin.merge_message(
        p_pms_name => p_fst_msg_id,
        p_pms_text => p_fst_name,
        p_pms_pse_id => p_fst_severity,
        p_pms_description => p_fst_description,
        p_pms_pmg_name => p_fst_fcl_id);
    end if;
    
    merge into fsm_status t
    using (select p_fst_id fst_id,
                  p_fst_fcl_id fst_fcl_id,
                  p_fst_fsg_id fst_fsg_id,
                  p_fst_msg_id fst_msg_id, 
                  l_pti_id fst_pti_id,
                  p_fst_retries_on_error fst_retries_on_error,
                  p_fst_retry_schedule fst_retry_schedule,
                  p_fst_retry_time fst_retry_time,
                  p_fst_icon_css fst_icon_css,
                  p_fst_name_css fst_name_css,
                  l_active fst_active
             from dual) s
       on (t.fst_id = s.fst_id and t.fst_fcl_id = s.fst_fcl_id)
     when matched then update set
          t.fst_fsg_id = s.fst_fsg_id,
          t.fst_msg_id = s.fst_msg_id,
          t.fst_retries_on_error = s.fst_retries_on_error,
          t.fst_retry_schedule = s.fst_retry_schedule,
          t.fst_retry_time = s.fst_retry_time,
          t.fst_icon_css = s.fst_icon_css,
          t.fst_name_css = s.fst_name_css,
          t.fst_active = s.fst_active
     when not matched then insert
          (fst_id, fst_fcl_id, fst_fsg_id, fst_msg_id, fst_pti_id, fst_active,
           fst_retries_on_error, fst_retry_schedule, fst_retry_time, fst_icon_css, fst_name_css)
          values
          (s.fst_id, s.fst_fcl_id, s.fst_fsg_id, s.fst_msg_id, s.fst_pti_id, s.fst_active,
           s.fst_retries_on_error, s.fst_retry_schedule, s.fst_retry_time, s.fst_icon_css, s.fst_name_css);
  end merge_status;
  
  procedure merge_status(
    p_row in fsm_status_v%rowtype)
  as
  begin
    merge_status(
      p_fst_id => p_row.fst_id,
      p_fst_fcl_id => p_row.fst_fcl_id,
      p_fst_fsg_id => p_row.fst_fsg_id,
      p_fst_name => p_row.fst_name,
      p_fst_description => p_row.fst_description,
      p_fst_severity => p_row.fst_severity,
      p_fst_msg_id => p_row.fst_msg_id,
      p_fst_retries_on_error => p_row.fst_retries_on_error,
      p_fst_retry_schedule => p_row.fst_retry_schedule,
      p_fst_retry_time => p_row.fst_retry_time,
      p_fst_icon_css => p_row.fst_icon_css,
      p_fst_name_css => p_row.fst_name_css,
      p_fst_active => pit_util.to_bool(p_row.fst_active));
  end merge_status;
  
  
  /**
    Procedure: delete_status
      See <FSM_ADMIN.delete_status>
   */
  procedure delete_status(
    p_fst_id in fsm_status_v.fst_id%type,
    p_fst_fcl_id in fsm_status_v.fst_fcl_id%type,
    p_force in boolean default false)
  as
    l_pti_id pit_util.ora_name_type;
  begin
    l_pti_id := replace(C_PTI_STATUS_PREFIX, C_FCL, p_fst_fcl_id) || p_fst_id;
    
    if p_force then 
      delete from fsm_transitions
       where ftr_fst_id = p_fst_id;
    end if;
    
    delete from fsm_status
     where fst_id = p_fst_id;
    
    pit_admin.delete_translatable_item(
      p_pti_id => l_pti_id,
      p_pti_pmg_name => p_fst_fcl_id);
  end delete_status;
  
  
  /**
    Procedure: merge_event
      See <FSM_ADMIN.merge_event>
   */
  procedure merge_event(
    p_fev_id in fsm_events_v.fev_id%type,
    p_fev_fcl_id in fsm_events_v.fev_fcl_id%type,
    p_fev_name in fsm_events_v.fev_name%type,
    p_fev_description in fsm_events_v.fev_description%type,
    p_fev_msg_id in fsm_events_v.fev_msg_id%type default msg.FSM_EVENT_RAISED,
    p_fev_raised_by_user in boolean default false,
    p_fev_command_label in fsm_events_v.fev_command_label%type default null,
    p_fev_button_icon in fsm_events_v.fev_button_icon%type default null,
    p_fev_button_highlight in boolean default false,
    p_fev_confirm_message in fsm_events_v.fev_confirm_message%type default null,
    p_fev_active in boolean default true)
  as
    l_pti_id pit_util.ora_name_type;
    l_active pit_util.flag_type;
    l_raised_by_user pit_util.flag_type;
    l_button_highlight pit_util.flag_type;
  begin
    l_pti_id := replace(C_PTI_EVENT_PREFIX, C_FCL, p_fev_fcl_id) || p_fev_id;
    l_active := bool_to_char(p_fev_active);    
    l_raised_by_user := bool_to_char(p_fev_raised_by_user);
    l_button_highlight := bool_to_char(p_fev_button_highlight);
    
    pit_admin.merge_translatable_item(
      p_pti_id => l_pti_id,
      p_pti_pml_name => pit.get_default_language,
      p_pti_pmg_name => p_fev_fcl_id,
      p_pti_name => p_fev_name,
      p_pti_display_name => p_fev_command_label,
      p_pti_description => p_fev_description);
      
    merge into fsm_events t
    using (select p_fev_id fev_id,
                  p_fev_fcl_id fev_fcl_id,
                  p_fev_msg_id fev_msg_id,
                  l_pti_id fev_pti_id,
                  l_active fev_active,                  
                  l_raised_by_user fev_raised_by_user,
                  p_fev_button_icon fev_button_icon,
                  l_button_highlight fev_button_highlight,
                  p_fev_confirm_message fev_confirm_message
             from dual) s
       on (t.fev_id = s.fev_id and t.fev_fcl_id = s.fev_fcl_id)
     when matched then update set
          fev_raised_by_user = s.fev_raised_by_user,
          fev_button_icon = s.fev_button_icon,
          fev_button_highlight = s.fev_button_highlight,
          fev_confirm_message = s.fev_confirm_message,
          fev_active = s.fev_active
     when not matched then insert 
          (fev_id, fev_fcl_id, fev_msg_id, fev_pti_id, fev_active,
           fev_raised_by_user, fev_button_icon, fev_button_highlight, fev_confirm_message)
          values  
          (s.fev_id, s.fev_fcl_id, s.fev_msg_id, s.fev_pti_id, s.fev_active,
           s.fev_raised_by_user, s.fev_button_icon, s.fev_button_highlight, s.fev_confirm_message);
  end merge_event;
  
  procedure merge_event(
    p_row in fsm_events_v%rowtype)
  as
  begin
    merge_event(
      p_fev_id => p_row.fev_id,
      p_fev_fcl_id => p_row.fev_fcl_id,
      p_fev_name => p_row.fev_name,
      p_fev_description => p_row.fev_description,
      p_fev_msg_id => p_row.fev_msg_id,
      p_fev_raised_by_user => pit_util.to_bool(p_row.fev_raised_by_user),
      p_fev_command_label => p_row.fev_command_label,
      p_fev_button_icon => p_row.fev_button_icon,
      p_fev_button_highlight => pit_util.to_bool(p_row.fev_button_highlight),
      p_fev_confirm_message => p_row.fev_confirm_message,
      p_fev_active => pit_util.to_bool(p_row.fev_active));
  end merge_event;
  
  
  /**
    Procedure: delete_event
      See <FSM_ADMIN.delete_event>
   */
  procedure delete_event(
    p_fev_id in fsm_events_v.fev_id%type,
    p_fev_fcl_id in fsm_events_v.fev_fcl_id%type,
    p_force in boolean default false)
  as
    l_pti_id pit_util.ora_name_type;
  begin
    l_pti_id := replace(C_PTI_EVENT_PREFIX, C_FCL, p_fev_fcl_id) || p_fev_id;
    if p_force then
      delete from fsm_transitions
       where ftr_fev_id = p_fev_id;
    end if;
    
    delete from fsm_events
     where fev_id = p_fev_id;
    
    pit_admin.delete_translatable_item(
      p_pti_id => l_pti_id,
      p_pti_pmg_name => p_fev_fcl_id);
  end delete_event;
  
  
  /**
    Procedure: merge_transition
      See <FSM_ADMIN.merge_transition>
   */
  procedure merge_transition(
    p_ftr_fst_id in fsm_transitions_v.ftr_fst_id%type,
    p_ftr_fev_id in fsm_transitions_v.ftr_fev_id%type,
    p_ftr_fcl_id in fsm_transitions_v.ftr_fcl_id%type,
    p_ftr_fsc_id in fsm_transitions_v.ftr_fsc_id%type,
    p_ftr_fst_list in fsm_transitions_v.ftr_fst_list%type,
    p_ftr_raise_automatically in boolean,
    p_ftr_raise_on_status in fsm_transitions_v.ftr_raise_on_status%type default fsm.C_OK,
    p_ftr_required_role in fsm_transitions_v.ftr_required_role%type default null,
    p_ftr_active in boolean default true)
  as
    l_active pit_util.flag_type;
    l_raise_automatically pit_util.flag_type;
  begin
    l_active := bool_to_char(p_ftr_active);
    l_raise_automatically := bool_to_char(p_ftr_raise_automatically);
    merge into fsm_transitions t
    using (select p_ftr_fst_id ftr_fst_id,
                  p_ftr_fev_id ftr_fev_id,
                  p_ftr_fcl_id ftr_fcl_id,
                  p_ftr_fsc_id ftr_fsc_id,
                  p_ftr_fst_list ftr_fst_list,
                  l_active ftr_active,
                  l_raise_automatically ftr_raise_automatically,
                  p_ftr_raise_on_status ftr_raise_on_status,
                  p_ftr_required_role ftr_required_role
             from dual) s
       on (t.ftr_fst_id = s.ftr_fst_id
           and t.ftr_fev_id = s.ftr_fev_id
           and t.ftr_fcl_id = s.ftr_fcl_id
           and t.ftr_fsc_id = s.ftr_fsc_id)
     when matched then update set
          ftr_fst_list = s.ftr_fst_list,
          ftr_active = s.ftr_active,
          ftr_raise_automatically = s.ftr_raise_automatically,
          ftr_raise_on_status = s.ftr_raise_on_status,
          ftr_required_role = s.ftr_required_role
     when not matched then insert
          (ftr_fst_id, ftr_fev_id, ftr_fcl_id, ftr_fsc_id, ftr_fst_list, ftr_active, 
           ftr_raise_automatically, ftr_raise_on_status, ftr_required_role)
          values
          (s.ftr_fst_id, s.ftr_fev_id, s.ftr_fcl_id, s.ftr_fsc_id, s.ftr_fst_list, s.ftr_active, 
           s.ftr_raise_automatically, s.ftr_raise_on_status, s.ftr_required_role);
  end merge_transition;
  
  procedure merge_transition(
    p_row in fsm_transitions_v%rowtype)
  as
  begin
    merge_transition(
      p_ftr_fst_id => p_row.ftr_fst_id,
      p_ftr_fev_id => p_row.ftr_fev_id,
      p_ftr_fcl_id => p_row.ftr_fcl_id,
      p_ftr_fsc_id => p_row.ftr_fsc_id,
      p_ftr_fst_list => p_row.ftr_fst_list,
      p_ftr_raise_automatically => pit_util.to_bool(p_row.ftr_raise_automatically),
      p_ftr_raise_on_status => p_row.ftr_raise_on_status,
      p_ftr_required_role => p_row.ftr_required_role,
      p_ftr_active => pit_util.to_bool(p_row.ftr_active));
  end merge_transition;
  
  
  /**
    Procedure: delete_transition
      See <FSM_ADMIN.delete_transition>
   */
  procedure delete_transition(
    p_ftr_fst_id in fsm_transitions_v.ftr_fst_id%type,
    p_ftr_fev_id in fsm_transitions_v.ftr_fev_id%type,
    p_ftr_fcl_id in fsm_transitions_v.ftr_fcl_id%type,
    p_ftr_fsc_id in fsm_transitions_v.ftr_fsc_id%type default 'MASTER'
)
  as
  begin
    delete from fsm_transitions
     where ftr_fst_id = p_ftr_fst_id
       and ftr_fev_id = p_ftr_fev_id
       and ftr_fcl_id = p_ftr_fcl_id
       and ftr_fsc_id = p_ftr_fsc_id;
  end delete_transition;
  
  
  /**
    Procedure: create_event_package
      See <FSM_ADMIN.create_event_package>
   */
  procedure create_event_package
  as
    C_PKG_NAME constant varchar2(30) := 'fsm_fev';
    l_sql_text clob :=
      'create or replace package ' || C_PKG_NAME || ' as' || fsm.C_CR;
    l_chunk varchar2(200 char);
    l_end_sql varchar2(50) := 'end ' || C_PKG_NAME || ';';

    cursor event_cur is
      select upper(fev_id) fev_id, upper(fev_fcl_id) fev_fcl_id
        from fsm_events
       where fev_active = pit_util.C_TRUE
       order by fev_fcl_id, fev_id;

    c_event_template constant varchar2(200) :=
      q'~  #FCL#_#FEV# constant varchar2(30 byte) := '#FEV#';~' || fsm.C_CR;
  begin
    for evt in event_cur loop
      l_chunk := replace(replace(c_event_template, 
                   '#FCL#', evt.fev_fcl_id),
                   '#FEV#', evt.fev_id);
      dbms_lob.writeappend(l_sql_text, length(l_chunk), l_chunk);
    end loop;
    dbms_lob.writeappend(l_sql_text, length(l_end_sql), l_end_sql);
    execute immediate l_sql_text;
  end create_event_package;
  
  
  /**
    Procedure: create_status_package
      See <FSM_ADMIN.create_status_package>
   */
  procedure create_status_package
  as
    C_PKG_NAME constant varchar2(30) := 'fsm_fst';
    l_sql_text clob :=
      'create or replace package ' || C_PKG_NAME || ' as' || fsm.C_CR;
    l_chunk varchar2(200 char);
    l_end_sql varchar2(50) := 'end ' || C_PKG_NAME || ';';

    cursor status_cur is
      select upper(fst_id) fst_id, upper(fst_fcl_id) fst_fcl_id
        from fsm_status
       where fst_active = pit_util.C_TRUE
       order by fst_fcl_id, fst_id;
    c_status_template constant varchar2(200) :=
      q'~  #FCL#_#FST# constant varchar2(30 byte) := '#FST#';~' || fsm.C_CR;
  begin
    for sta in status_cur loop
      l_chunk := replace(replace(c_status_template,
                   '#FCL#', sta.fst_fcl_id),
                   '#FST#', sta.fst_id);
      dbms_lob.writeappend(l_sql_text, length(l_chunk), l_chunk);
    end loop;
    dbms_lob.writeappend(l_sql_text, length(l_end_sql), l_end_sql);
    execute immediate l_sql_text;
  end create_status_package;
  
  
  /**
    Procedure: export_class
      See <FSM_ADMIN.export_class>
   */
  function export_class(
    p_fcl_id in fsm_classes_v.fcl_id%type)
    return clob
  as
    l_script clob;
    C_CR constant pit_util.flag_type := chr(10);
  begin
    with templates as (
           select uttm_text template, uttm_mode
             from utl_text_templates
            where uttm_name = 'EXPORT_FSM'
              and uttm_type = 'FSM')
    select utl_text.generate_text(cursor(
             select template, fcl_id, fcl_name, fcl_description,
                    case fcl_active when pit_util.C_TRUE then 'true' else 'false' end fcl_active,
                    utl_text.generate_text(cursor(
                      select template, fsg_id, fsg_fcl_id, fsg_name, fsg_description,
                             fsg_icon_css, fsg_name_css,
                             case fsg_active when pit_util.C_TRUE then 'true' else 'false' end fsg_active
                        from fsm_status_groups_v
                       cross join templates
                       where uttm_mode = 'FSG'
                         and fsg_fcl_id = fcl_id
                    ), C_CR) fsg_script,
                    utl_text.generate_text(cursor(
                      select template, fst_id, fst_fcl_id, fst_fsg_id, fst_msg_id, fst_pti_id, fst_name, fst_description,                             
                             fst_retries_on_error, fst_severity, fst_retry_schedule, 
                             coalesce(to_char(fst_retry_time), 'null') fst_retry_time, fst_icon_css, fst_name_css,
                             case fst_active when pit_util.C_TRUE then 'true' else 'false' end fst_active
                        from fsm_status_v
                       cross join templates
                       where uttm_mode = 'FST'
                         and fst_fcl_id = fcl_id
                    ), C_CR) fst_script,
                    utl_text.generate_text(cursor(
                      select template, fev_id, fev_fcl_id, fev_msg_id, fev_name, fev_description,
                             case fev_raised_by_user when pit_util.C_TRUE then 'true' else 'false' end fev_raised_by_user,
                             fev_command_label, fev_button_highlight, fev_confirm_message, fev_button_icon,
                             case fev_active when pit_util.C_TRUE then 'true' else 'false' end fev_active
                        from fsm_events_v
                       cross join templates
                       where uttm_mode = 'FEV'
                         and fev_fcl_id = fcl_id
                    ), C_CR) fev_script,
                    utl_text.generate_text(cursor(
                      select template, ftr_fst_id, ftr_fev_id, ftr_fcl_id, ftr_fst_list, ftr_required_role, ftr_raise_on_status,
                             case ftr_active when pit_util.C_TRUE then 'true' else 'false' end ftr_raise_automatically,                             
                             case ftr_active when pit_util.C_TRUE then 'true' else 'false' end ftr_active
                        from fsm_transitions_v
                       cross join templates
                       where uttm_mode = 'FTR'
                         and ftr_fcl_id = fcl_id
                    ), C_CR) ftr_script
               from fsm_classes_v
              cross join templates
              where uttm_mode = 'FRAME'
                and fcl_id = p_fcl_id
           )) resultat
      into l_script
      from dual;
      
    return l_script;
  end export_class;
  

end fsm_admin;
/