create or replace package body fsm_admin
as
  
  C_FCL constant varchar2(20 byte) := '#FCL#';
  C_PTI_CLASS_PREFIX varchar2(20 byte) := 'FCL_';
  C_PTI_GROUP_PREFIX varchar2(20 byte) := 'FSG_#FCL#_';
  C_PTI_STATUS_PREFIX varchar2(20 byte) := 'FST_#FCL#_';
  C_PTI_EVENT_PREFIX varchar2(20 byte) := 'FEV_#FCL#_';
  
  
  g_active fsm.flag_type;
  g_pti_id fsm.ora_name_type;
  
  /* Helper */
  function bool_to_char(
    p_bool in boolean)
    return varchar2
  as
  begin
    return case when p_bool then fsm.C_TRUE else fsm.C_FALSE end;
  end bool_to_char;
  
  
  /* INTERFACE */
  procedure merge_class(
    p_fcl_id in fsm_classes_v.fcl_id%type,
    p_fcl_name in fsm_classes_v.fcl_name%type,
    p_fcl_description in fsm_classes_v.fcl_description%type,
    p_fcl_active in boolean default true)
  as
  begin
    g_active := bool_to_char(p_fcl_active);
    g_pti_id := C_PTI_CLASS_PREFIX || p_fcl_id;
    
    pit_admin.merge_translatable_item(
      p_pti_id => g_pti_id,
      p_pti_pml_name => pit.get_default_language,
      p_pti_pmg_name => p_fcl_id,
      p_pti_name => p_fcl_name,
      p_pti_description => p_fcl_description);
    
    merge into fsm_classes t
    using (select p_fcl_id fcl_id,
                  g_pti_id fcl_pti_id,
                  g_active fcl_active
             from dual) s
       on (t.fcl_id = s.fcl_id)
     when matched then update set
          fcl_active = s.fcl_active
     when not matched then insert (fcl_id, fcl_pti_id, fcl_active)
          values (s.fcl_id, s.fcl_pti_id, s.fcl_active);
  end merge_class;
  
  
  procedure delete_class(
    p_fcl_id in fsm_classes_v.fcl_id%type,
    p_force in boolean default false)
  as
  begin
    g_pti_id := C_PTI_CLASS_PREFIX || p_fcl_id;
    
    if p_force then
      delete from fsm_transitions
       where ftr_fcl_id = p_fcl_id;
      
      delete from fsm_status
       where fst_fcl_id = p_fcl_id;
       
      delete from fsm_events
       where fev_fcl_id = p_fcl_id;
    end if;
    
    delete from fsm_classes
     where fcl_id = p_fcl_id;
    
    pit_admin.delete_translatable_item(
      p_pti_id => g_pti_id);
  end delete_class;  
    
    
  procedure merge_status_group(
    p_fsg_id in fsm_status_groups_v.fsg_id%type,
    p_fsg_fcl_id in fsm_status_groups_v.fsg_fcl_id%type,
    p_fsg_name in fsm_status_groups_v.fsg_name%type,
    p_fsg_description in fsm_status_groups_v.fsg_description%type,
    p_fsg_icon_css in fsm_status_groups_v.fsg_icon_css%type default null,
    p_fsg_name_css in fsm_status_groups_v.fsg_name_css%type default null,
    p_fsg_active in boolean default true)
  as
  begin
    g_active := bool_to_char(p_fsg_active);
    g_pti_id := replace(C_PTI_GROUP_PREFIX, C_FCL, p_fsg_fcl_id) || p_fsg_id;
    
    pit_admin.merge_translatable_item(
      p_pti_id => g_pti_id,
      p_pti_pml_name => pit.get_default_language,
      p_pti_pmg_name => p_fsg_fcl_id,
      p_pti_name => p_fsg_name,
      p_pti_description => p_fsg_description);
      
    merge into fsm_status_groups t
    using (select p_fsg_id fsg_id,
                  p_fsg_fcl_id fsg_fcl_id,
                  g_pti_id fsg_pti_id,
                  p_fsg_icon_css fsg_icon_css,
                  p_fsg_name_css fsg_name_css,
                  g_active fsg_active
             from dual) s
       on (t.fsg_id = s.fsg_id)
     when matched then update set
          t.fsg_icon_css = s.fsg_icon_css,
          t.fsg_name_css = s.fsg_name_css,
          t.fsg_active = s.fsg_active
     when not matched then insert(fsg_id, fsg_fcl_id, fsg_pti_id, fsg_icon_css, fsg_name_css, fsg_active)
          values(s.fsg_id, s.fsg_fcl_id, s.fsg_pti_id, s.fsg_icon_css, s.fsg_name_css, s.fsg_active);
  end merge_status_group;
  
  
  procedure delete_status_group(
    p_fsg_id in fsm_status_groups_v.fsg_id%type,
    p_fsg_fcl_id in fsm_status_groups_v.fsg_fcl_id%type,
    p_force in boolean default false)
  as
  begin
    g_pti_id := replace(C_PTI_GROUP_PREFIX, C_FCL, p_fsg_fcl_id) || p_fsg_id;
    
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
      p_pti_id => g_pti_id);
  end delete_status_group;
    
    
  procedure merge_status(
    p_fst_id in fsm_status_v.fst_id%type,
    p_fst_fcl_id in fsm_status_v.fst_fcl_id%type,
    p_fst_fsg_id in fsm_status_v.fst_fsg_id%type,
    p_fst_name in fsm_status_v.fst_name%type,
    p_fst_description in fsm_status_v.fst_description%type,
    p_fst_msg_id in fsm_status_v.fst_msg_id%type default msg.FSM_STATUS_CHANGED,
    p_fst_retries_on_error in fsm_status_v.fst_retries_on_error%type default 0,
    p_fst_retry_schedule in fsm_status_v.fst_retry_schedule%type default null,
    p_fst_retry_time in fsm_status_v.fst_retry_time%type default null,
    p_fst_icon_css in fsm_status_v.fst_icon_css%type default null,
    p_fst_name_css in fsm_status_v.fst_name_css%type default null,
    p_fst_active in boolean default true)
  as
    g_active fsm.flag_type;
  begin
    g_active := bool_to_char(p_fst_active);
    g_pti_id := replace(C_PTI_STATUS_PREFIX, C_FCL, p_fst_fcl_id) || p_fst_id;
    
    pit_admin.merge_translatable_item(
      p_pti_id => g_pti_id,
      p_pti_pml_name => pit.get_default_language,
      p_pti_pmg_name => p_fst_fcl_id,
      p_pti_name => p_fst_name,
      p_pti_description => p_fst_description);
    
    merge into fsm_status t
    using (select p_fst_id fst_id,
                  p_fst_fcl_id fst_fcl_id,
                  p_fst_fsg_id fst_fsg_id,
                  p_fst_msg_id fst_msg_id, 
                  g_pti_id fst_pti_id,
                  p_fst_retries_on_error fst_retries_on_error,
                  p_fst_retry_schedule fst_retry_schedule,
                  p_fst_retry_time fst_retry_time,
                  p_fst_icon_css fst_icon_css,
                  p_fst_name_css fst_name_css,
                  g_active fst_active
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
  
  
  procedure delete_status(
    p_fst_id in fsm_status_v.fst_id%type,
    p_fst_fcl_id in fsm_status_v.fst_fcl_id%type,
    p_force in boolean default false)
  as
  begin
    g_pti_id := replace(C_PTI_STATUS_PREFIX, C_FCL, p_fst_fcl_id) || p_fst_id;
    
    if p_force then 
      delete from fsm_transitions
       where ftr_fst_id = p_fst_id;
    end if;
    
    delete from fsm_status
     where fst_id = p_fst_id;
    
    pit_admin.delete_translatable_item(
      p_pti_id => g_pti_id);
  end delete_status;
  
  
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
    g_active fsm.flag_type;
    l_raised_by_user fsm.flag_type;
    l_button_highlight fsm.flag_type;
  begin
    g_pti_id := replace(C_PTI_EVENT_PREFIX, C_FCL, p_fev_fcl_id) || p_fev_id;
    g_active := bool_to_char(p_fev_active);    
    l_raised_by_user := bool_to_char(p_fev_raised_by_user);
    l_button_highlight := bool_to_char(p_fev_button_highlight);
    
    pit_admin.merge_translatable_item(
      p_pti_id => g_pti_id,
      p_pti_pml_name => pit.get_default_language,
      p_pti_pmg_name => p_fev_fcl_id,
      p_pti_name => p_fev_name,
      p_pti_display_name => p_fev_command_label,
      p_pti_description => p_fev_description);
      
    merge into fsm_events t
    using (select p_fev_id fev_id,
                  p_fev_fcl_id fev_fcl_id,
                  p_fev_msg_id fev_msg_id,
                  g_pti_id fev_pti_id,
                  g_active fev_active,                  
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
  
  
  procedure delete_event(
    p_fev_id in fsm_events_v.fev_id%type,
    p_fev_fcl_id in fsm_events_v.fev_fcl_id%type,
    p_force in boolean default false)
  as
  begin
    g_pti_id := replace(C_PTI_EVENT_PREFIX, C_FCL, p_fev_fcl_id) || p_fev_id;
    if p_force then
      delete from fsm_transitions
       where ftr_fev_id = p_fev_id;
    end if;
    
    delete from fsm_events
     where fev_id = p_fev_id;
    
    pit_admin.delete_translatable_item(
      p_pti_id => g_pti_id);
  end delete_event;
    
    
  procedure merge_transition(
    p_ftr_fst_id in fsm_transitions_v.ftr_fst_id%type,
    p_ftr_fev_id in fsm_transitions_v.ftr_fev_id%type,
    p_ftr_fcl_id in fsm_transitions_v.ftr_fcl_id%type,
    p_ftr_fst_list in fsm_transitions_v.ftr_fst_list%type,
    p_ftr_raise_automatically in boolean,
    p_ftr_raise_on_status in fsm_transitions_v.ftr_raise_on_status%type default 0,
    p_ftr_required_role in fsm_transitions_v.ftr_required_role%type default null,
    p_ftr_active in boolean default true)
  as
    g_active fsm.flag_type;
    l_raise_automatically fsm.flag_type;
  begin
    g_active := bool_to_char(p_ftr_active);
    l_raise_automatically := bool_to_char(p_ftr_raise_automatically);
    merge into fsm_transitions t
    using (select p_ftr_fst_id ftr_fst_id,
                  p_ftr_fev_id ftr_fev_id,
                  p_ftr_fcl_id ftr_fcl_id,
                  p_ftr_fst_list ftr_fst_list,
                  g_active ftr_active,
                  l_raise_automatically ftr_raise_automatically,
                  p_ftr_raise_on_status ftr_raise_on_status,
                  p_ftr_required_role ftr_required_role
             from dual) s
       on (t.ftr_fst_id = s.ftr_fst_id
           and t.ftr_fev_id = s.ftr_fev_id
           and t.ftr_fcl_id = s.ftr_fcl_id)
     when matched then update set
          ftr_fst_list = s.ftr_fst_list,
          ftr_active = s.ftr_active,
          ftr_raise_automatically = s.ftr_raise_automatically,
          ftr_raise_on_status = s.ftr_raise_on_status,
          ftr_required_role = s.ftr_required_role
     when not matched then insert
          (ftr_fst_id, ftr_fev_id, ftr_fcl_id, ftr_fst_list, ftr_active, 
           ftr_raise_automatically, ftr_raise_on_status, ftr_required_role)
          values
          (s.ftr_fst_id, s.ftr_fev_id, s.ftr_fcl_id, s.ftr_fst_list, s.ftr_active, 
           s.ftr_raise_automatically, s.ftr_raise_on_status, s.ftr_required_role);
  end merge_transition;
  
  
  procedure delete_transition(
    p_ftr_fst_id in fsm_transitions_v.ftr_fst_id%type,
    p_ftr_fev_id in fsm_transitions_v.ftr_fev_id%type,
    p_ftr_fcl_id in fsm_transitions_v.ftr_fcl_id%type)
  as
  begin
    delete from fsm_transitions
     where ftr_fst_id = p_ftr_fst_id
       and ftr_fev_id = p_ftr_fev_id
       and ftr_fcl_id = p_ftr_fcl_id;
  end delete_transition;
  

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
       where fev_active = fsm.C_TRUE
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
       where fst_active = fsm.C_TRUE
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
  
  
  function export_class(
    p_fcl_id in fsm_classes.fcl_id%type)
    return clob
  as
  begin
    return null;
  end export_class;
  

end fsm_admin;
/