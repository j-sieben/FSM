create or replace package body fsm_admin_pkg
as
  
  /* Helper */
  function bool_to_char(
    p_bool in boolean)
    return varchar2
  as
  begin
    return case when p_bool then fsm_pkg.C_TRUE else fsm_pkg.C_FALSE end;
  end bool_to_char;
  
  
  /* INTERFACE */
  procedure merge_class(
    p_fcl_id in fsm_class.fcl_id%type,
    p_fcl_name in fsm_class.fcl_name%type,
    p_fcl_description in fsm_class.fcl_description%type,
    p_fcl_active in boolean default true)
  as
    l_active fsm_pkg.flag_type;
  begin
    l_active := bool_to_char(p_fcl_active);
    merge into fsm_class c
    using (select p_fcl_id fcl_id,
                  p_fcl_name fcl_name,
                  p_fcl_description fcl_description,
                  l_active fcl_active
             from dual) s
       on (c.fcl_id = s.fcl_id)
     when matched then update set
          fcl_name = s.fcl_name,
          fcl_description = s.fcl_description,
          fcl_active = s.fcl_active
     when not matched then insert (fcl_id, fcl_name, fcl_description, fcl_active)
          values (s.fcl_id, s.fcl_name, s.fcl_description, s.fcl_active);
  end merge_class;
  
  
  procedure delete_class(
    p_fcl_id in fsm_class.fcl_id%type,
    p_force in boolean default false)
  as
  begin
    if p_force then
      delete from fsm_transition
       where ftr_fcl_id = p_fcl_id;
      
      delete from fsm_status
       where fst_fcl_id = p_fcl_id;
       
      delete from fsm_event
       where fev_fcl_id = p_fcl_id;
    end if;
    
    delete from fsm_class
     where fcl_id = p_fcl_id;
  end delete_class;  
    
    
  procedure merge_status_group(
    p_fsg_id in fsm_status_group.fsg_id%type,
    p_fsg_name in fsm_status_group.fsg_name%type,
    p_fsg_description in fsm_status_group.fsg_description%type,
    p_fsg_icon_css in fsm_status_group.fsg_icon_css%type default null,
    p_fsg_name_css in fsm_status_group.fsg_name_css%type default null,
    p_fsg_active in boolean default true)
  as
    l_active fsm_pkg.flag_type;
  begin
    l_active := bool_to_char(p_fsg_active);
    merge into fsm_status_group t
    using (select p_fsg_id fsg_id,
                  p_fsg_name fsg_name,
                  p_fsg_description fsg_description,
                  p_fsg_icon_css fsg_icon_css,
                  p_fsg_name_css fsg_name_css,
                  l_active fsg_active
             from dual) s
       on (t.fsg_id = s.fsg_id)
     when matched then update set
          t.fsg_name = s.fsg_name,
          t.fsg_description = s.fsg_description,
          t.fsg_icon_css = s.fsg_icon_css,
          t.fsg_name_css = s.fsg_name_css,
          t.fsg_active = s.fsg_active
     when not matched then insert(fsg_id, fsg_name, fsg_description, fsg_icon_css, fsg_name_css, fsg_active)
          values(s.fsg_id, s.fsg_name, s.fsg_description, s.fsg_icon_css, s.fsg_name_css, s.fsg_active);
  end merge_status_group;
  
  
  procedure delete_status_group(
    p_fsg_id in fsm_status.fst_id%type,
    p_force in boolean default false)
  as
  begin
    if p_force then
      delete from fsm_transition
       where ftr_fst_id in (
             select fst_id
               from fsm_status
              where fst_fsg_id = p_fsg_id);
      delete from fsm_status
       where fst_fsg_id = p_fsg_id;
    end if;
    
    delete from fsm_status_group
     where fsg_id = p_fsg_id;
  end delete_status_group;
    
    
  procedure merge_status(
    p_fst_id in fsm_status.fst_id%type,
    p_fst_fcl_id in fsm_status.fst_fcl_id%type,
    p_fst_fsg_id in fsm_status.fst_fsg_id%type,
    p_fst_name in fsm_status.fst_name%type,
    p_fst_description in fsm_status.fst_description%type,
    p_fst_msg_id in fsm_status.fst_msg_id%type default msg.FSM_STATUS_CHANGED,
    p_fst_retries_on_error in fsm_status.fst_retries_on_error%type default 0,
    p_fst_retry_schedule in fsm_status.fst_retry_schedule%type default null,
    p_fst_retry_time in fsm_status.fst_retry_time%type default null,
    p_fst_icon_css in fsm_status.fst_icon_css%type default null,
    p_fst_name_css in fsm_status.fst_name_css%type default null,
    p_fst_active in boolean default true)
  as
    l_active fsm_pkg.flag_type;
  begin
    l_active := bool_to_char(p_fst_active);
    merge into fsm_status t
    using (select p_fst_id fst_id,
                  p_fst_fcl_id fst_fcl_id,
                  p_fst_fsg_id fst_fsg_id,
                  p_fst_msg_id fst_msg_id, 
                  p_fst_name fst_name,
                  p_fst_description fst_description,
                  l_active fst_active,
                  p_fst_retries_on_error fst_retries_on_error,
                  p_fst_retry_schedule fst_retry_schedule,
                  p_fst_retry_time fst_retry_time,
                  p_fst_icon_css fst_icon_css,
                  p_fst_name_css fst_name_css
             from dual) s
       on (t.fst_id = s.fst_id and t.fst_fcl_id = s.fst_fcl_id)
     when matched then update set
          t.fst_fsg_id = s.fst_fsg_id,
          t.fst_msg_id = s.fst_msg_id,
          t.fst_name = s.fst_name,
          t.fst_description = s.fst_description,
          t.fst_active = s.fst_active,
          t.fst_retries_on_error = s.fst_retries_on_error,
          t.fst_retry_schedule = s.fst_retry_schedule,
          t.fst_retry_time = s.fst_retry_time,
          t.fst_icon_css = s.fst_icon_css,
          t.fst_name_css = s.fst_name_css
     when not matched then insert
          (fst_id, fst_fcl_id, fst_fsg_id, fst_msg_id, fst_name, fst_description, fst_active,
           fst_retries_on_error, fst_retry_schedule, fst_retry_time, fst_icon_css, fst_name_css)
          values
          (s.fst_id, s.fst_fcl_id, s.fst_fsg_id, s.fst_msg_id, s.fst_name, s.fst_description, s.fst_active,
           s.fst_retries_on_error, s.fst_retry_schedule, s.fst_retry_time, s.fst_icon_css, s.fst_name_css);
  end merge_status;
  
  
  procedure delete_status(
    p_fst_id in fsm_status.fst_id%type,
    p_force in boolean default false)
  as
  begin
    if p_force then 
      delete from fsm_transition
       where ftr_fst_id = p_fst_id;
    end if;
    
    delete from fsm_status
     where fst_id = p_fst_id;
  end delete_status;
  
  
  procedure merge_event(
    p_fev_id in fsm_event.fev_id%type,
    p_fev_fcl_id in fsm_event.fev_fcl_id%type,
    p_fev_name in fsm_event.fev_name%type,
    p_fev_description in fsm_event.fev_description%type,
    p_fev_msg_id in fsm_event.fev_msg_id%type default msg.FSM_EVENT_RAISED,
    p_fev_raised_by_user in boolean default false,
    p_fev_command in fsm_event.fev_command%type default null,
    p_fev_button_icon in fsm_event.fev_button_icon%type default null,
    p_fev_button_highlight in boolean default false,
    p_fev_confirm_message in fsm_event.fev_confirm_message%type default null,
    p_fev_active in boolean default true)
  as
    l_active fsm_pkg.flag_type;
    l_raised_by_user fsm_pkg.flag_type;
    l_button_highlight fsm_pkg.flag_type;
  begin
    l_active := bool_to_char(p_fev_active);
    l_raised_by_user := bool_to_char(p_fev_raised_by_user);
    l_button_highlight := bool_to_char(p_fev_button_highlight);
    merge into fsm_event t
    using (select p_fev_id fev_id,
                  p_fev_fcl_id fev_fcl_id,
                  p_fev_msg_id fev_msg_id,
                  p_fev_name fev_name,
                  p_fev_description fev_description,
                  l_active fev_active,
                  p_fev_command fev_command,                  
                  l_raised_by_user fev_raised_by_user,
                  p_fev_button_icon fev_button_icon,
                  l_button_highlight fev_button_highlight,
                  p_fev_confirm_message fev_confirm_message
             from dual) s
       on (t.fev_id = s.fev_id and t.fev_fcl_id = s.fev_fcl_id)
     when matched then update set
          fev_name = s.Fev_name,
          fev_description = s.fev_description,
          fev_command = s.fev_command,
          fev_active = s.fev_active,
          fev_raised_by_user = s.fev_raised_by_user,
          fev_button_icon = s.fev_button_icon,
          fev_button_highlight = s.fev_button_highlight,
          fev_confirm_message = s.fev_confirm_message
     when not matched then insert 
          (fev_id, fev_fcl_id, fev_msg_id, fev_name, fev_description, fev_command, fev_active,
           fev_raised_by_user, fev_button_icon, fev_button_highlight, fev_confirm_message)
          values  
          (s.fev_id, s.fev_fcl_id, s.fev_msg_id, s.fev_name, s.fev_description, s.fev_command, s.fev_active,
           s.fev_raised_by_user, s.fev_button_icon, s.fev_button_highlight, s.fev_confirm_message);
  end merge_event;
  
  
  procedure delete_event(
    p_fev_id in fsm_event.fev_id%type,
    p_force in boolean default false)
  as
  begin
    if p_force then
      delete from fsm_transition
       where ftr_fev_id = p_fev_id;
    end if;
    
    delete from fsm_event
     where fev_id = p_fev_id;
  end delete_event;
    
    
  procedure merge_transition(
    p_ftr_fst_id in fsm_transition.ftr_fst_id%type,
    p_ftr_fev_id in fsm_transition.ftr_fev_id%type,
    p_ftr_fcl_id in fsm_transition.ftr_fcl_id%type,
    p_ftr_fst_list in fsm_transition.ftr_fst_list%type,
    p_ftr_raise_automatically in boolean,
    p_ftr_raise_on_status in fsm_transition.ftr_raise_on_status%type default 0,
    p_ftr_required_role in fsm_transition.ftr_required_role%type default null,
    p_ftr_active in boolean default true)
  as
    l_active fsm_pkg.flag_type;
    l_raise_automatically fsm_pkg.flag_type;
  begin
    l_active := bool_to_char(p_ftr_active);
    l_raise_automatically := bool_to_char(p_ftr_raise_automatically);
    merge into fsm_transition t
    using (select p_ftr_fst_id ftr_fst_id,
                  p_ftr_fev_id ftr_fev_id,
                  p_ftr_fcl_id ftr_fcl_id,
                  p_ftr_fst_list ftr_fst_list,
                  l_active ftr_active,
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
    p_ftr_fst_id in fsm_transition.ftr_fst_id%type,
    p_ftr_fev_id in fsm_transition.ftr_fev_id%type,
    p_ftr_fcl_id in fsm_transition.ftr_fcl_id%type)
  as
  begin
    delete from fsm_transition
     where ftr_fst_id = p_ftr_fst_id
       and ftr_fev_id = p_ftr_fev_id
       and ftr_fcl_id = p_ftr_fcl_id;
  end delete_transition;
  

  procedure create_event_package
  as
    C_PKG_NAME constant varchar2(30) := 'fsm_fev';
    l_sql_text clob :=
      'create or replace package ' || C_PKG_NAME || ' as' || fsm_pkg.C_CR;
    l_chunk varchar2(200 char);
    l_end_sql varchar2(50) := 'end ' || C_PKG_NAME || ';';

    cursor event_cur is
      select upper(fev_id) fev_id, upper(fev_fcl_id) fev_fcl_id
        from fsm_event
       where fev_active = fsm_pkg.C_TRUE
       order by fev_fcl_id, fev_id;

    c_event_template constant varchar2(200) :=
      q'~  #FCL#_#FEV# constant varchar2(30 byte) := '#FEV#';~' || fsm_pkg.C_CR;
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
      'create or replace package ' || C_PKG_NAME || ' as' || fsm_pkg.C_CR;
    l_chunk varchar2(200 char);
    l_end_sql varchar2(50) := 'end ' || C_PKG_NAME || ';';

    cursor status_cur is
      select upper(fst_id) fst_id, upper(fst_fcl_id) fst_fcl_id
        from fsm_status
       where fst_active = fsm_pkg.C_TRUE
       order by fst_fcl_id, fst_id;
    c_status_template constant varchar2(200) :=
      q'~  #FCL#_#FST# constant varchar2(30 byte) := '#FST#';~' || fsm_pkg.C_CR;
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
    p_fcl_id in fsm_class.fcl_id%type)
    return clob
  as
  begin
    null;
  end export_class;
  

end fsm_admin_pkg;
/