create or replace package body &TOOLKIT._admin_pkg
as

  C_PKG constant utl_&TOOLKIT..ora_name_type := $$PLSQL_UNIT;  
  
  /* Helper */
  function bool_to_char(
    p_bool in boolean)
    return varchar2
  as
  begin
    return case when p_bool then utl_&TOOLKIT..C_TRUE else utl_&TOOLKIT..C_FALSE end;
  end bool_to_char;
  
  
  /* INTERFACE */
  procedure merge_class(
    p_fcl_id in &TOOLKIT._class.fcl_id%type,
    p_fcl_name in &TOOLKIT._class.fcl_name%type,
    p_fcl_description in &TOOLKIT._class.fcl_description%type,
    p_fcl_active in boolean default true)
  as
    l_active utl_&TOOLKIT..flag_type;
  begin
    l_active := bool_to_char(p_fcl_active);
    merge into &TOOLKIT._class c
    using (select p_fcl_id fcl_id,
                  p_fcl_name fcl_name,
                  p_fcl_description fcl_description,
                  l_active fcl_active
             from dual) v
       on (c.fcl_id = v.fcl_id)
     when matched then update set
          fcl_name = v.fcl_name,
          fcl_description = v.fcl_description,
          fcl_active = v.fcl_active
     when not matched then insert (fcl_id, fcl_name, fcl_description, fcl_active)
          values (v.fcl_id, v.fcl_name, v.fcl_description, v.fcl_active);
  end merge_class;
  
  
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
    p_fev_confirm_message in &TOOLKIT._event.fev_confirm_message%type default null)
  as
    l_active utl_&TOOLKIT..flag_type;
    l_raised_by_user utl_&TOOLKIT..flag_type;
    l_button_highlight utl_&TOOLKIT..flag_type;
  begin
    l_active := bool_to_char(p_fev_active);
    l_raised_by_user := bool_to_char(p_fev_raised_by_user);
    l_button_highlight := bool_to_char(p_fev_button_highlight);
    merge into &TOOLKIT._event e
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
             from dual) v
       on (e.fev_id = v.fev_id and e.fev_fcl_id = v.fev_fcl_id)
     when matched then update set
          fev_name = v.Fev_name,
          fev_description = v.fev_description,
          fev_command = v.fev_command,
          fev_active = v.fev_active,
          fev_raised_by_user = v.fev_raised_by_user,
          fev_button_icon = v.fev_button_icon,
          fev_button_highlight = v.fev_button_highlight,
          fev_confirm_message = v.fev_confirm_message
     when not matched then insert 
          (fev_id, fev_fcl_id, fev_msg_id, fev_name, fev_description, fev_command, fev_active,
           fev_raised_by_user, fev_button_icon, fev_button_highlight, fev_confirm_message)
          values  
          (v.fev_id, v.fev_fcl_id, v.fev_msg_id, v.fev_name, v.fev_description, v.fev_command, v.fev_active,
           v.fev_raised_by_user, v.fev_button_icon, v.fev_button_highlight, v.fev_confirm_message);
  end merge_event;
    
    
  procedure merge_status(
    p_fst_id in &TOOLKIT._status.fst_id%type,
    p_fst_fcl_id in &TOOLKIT._status.fst_fcl_id%type,
    p_fst_msg_id in &TOOLKIT._status.fst_msg_id%type,
    p_fst_name in &TOOLKIT._status.fst_name%type,
    p_fst_description in &TOOLKIT._status.fst_description%type,
    p_fst_active in boolean default true,
    p_fst_retries_on_error in &TOOLKIT._status.fst_retries_on_error%type default 0,
    p_fst_retry_schedule in &TOOLKIT._status.fst_retry_schedule%type default null,
    p_fst_retry_time in &TOOLKIT._status.fst_retry_time%type default null)
  as
    l_active utl_&TOOLKIT..flag_type;
  begin
    l_active := bool_to_char(p_fst_active);
    merge into &TOOLKIT._status s
    using (select p_fst_id fst_id,
                  p_fst_fcl_id fst_fcl_id,
                  p_fst_msg_id fst_msg_id, 
                  p_fst_name fst_name,
                  p_fst_description fst_description,
                  l_active fst_active,
                  p_fst_retries_on_error fst_retries_on_error,
                  p_fst_retry_schedule fst_retry_schedule,
                  p_fst_retry_time fst_retry_time
             from dual) v
       on (s.fst_id = v.fst_id and s.fst_fcl_id = v.fst_fcl_id)
     when matched then update set
          fst_msg_id = v.fst_msg_id,
          fst_description = v.fst_description,
          fst_active = v.fst_active,
          fst_retries_on_error = v.fst_retries_on_error,
          fst_retry_schedule = v.fst_retry_schedule,
          fst_retry_time = v.fst_retry_time
     when not matched then insert
          (fst_id, fst_fcl_id, fst_msg_id, fst_name, fst_description, fst_active,
           fst_retries_on_error, fst_retry_schedule, fst_retry_time)
          values
          (v.fst_id, v.fst_fcl_id, v.fst_msg_id, v.fst_name, v.fst_description, v.fst_active,
           v.fst_retries_on_error, v.fst_retry_schedule, v.fst_retry_time);
  end merge_status;    
    
    
  procedure merge_transition(
    p_ftr_fst_id in varchar2,
    p_ftr_fev_id in varchar2,
    p_ftr_fcl_id in varchar2,
    p_ftr_fst_list in varchar2,
    p_ftr_active in boolean default true,
    p_ftr_raise_automatically in boolean,
    p_ftr_raise_on_status in number default 0,
    p_ftr_required_role in varchar2 default null)
  as
    l_active utl_&TOOLKIT..flag_type;
    l_raise_automatically utl_&TOOLKIT..flag_type;
  begin
    l_active := bool_to_char(p_ftr_active);
    l_raise_automatically := bool_to_char(p_ftr_raise_automatically);
    merge into &TOOLKIT._transition t
    using (select p_ftr_fst_id ftr_fst_id,
                  p_ftr_fev_id ftr_fev_id,
                  p_ftr_fcl_id ftr_fcl_id,
                  p_ftr_fst_list ftr_fst_list,
                  l_active ftr_active,
                  l_raise_automatically ftr_raise_automatically,
                  p_ftr_raise_on_status ftr_raise_on_status,
                  p_ftr_required_role ftr_required_role
             from dual) v
       on (t.ftr_fst_id = v.ftr_fst_id
           and t.ftr_fev_id = v.ftr_fev_id
           and t.ftr_fcl_id = v.ftr_fcl_id)
     when matched then update set
          ftr_fst_list = v.ftr_fst_list,
          ftr_active = v.ftr_active,
          ftr_raise_automatically = v.ftr_raise_automatically,
          ftr_raise_on_status = v.ftr_raise_on_status,
          ftr_required_role = v.ftr_required_role
     when not matched then insert
          (ftr_fst_id, ftr_fev_id, ftr_fcl_id, ftr_fst_list, ftr_active, 
           ftr_raise_automatically, ftr_raise_on_status, ftr_required_role)
          values
          (v.ftr_fst_id, v.ftr_fev_id, v.ftr_fcl_id, v.ftr_fst_list, v.ftr_active, 
           v.ftr_raise_automatically, v.ftr_raise_on_status, v.ftr_required_role);
  end merge_transition;
  

  procedure create_event_package
  as
    C_PKG_NAME constant varchar2(30) := '&TOOLKIT._fev';
    l_sql_text clob :=
      'create or replace package ' || C_PKG_NAME || ' as' || utl_&TOOLKIT..C_CR;
    l_chunk varchar2(200 char);
    l_end_sql varchar2(50) := 'end ' || C_PKG_NAME || ';';

    cursor event_cur is
      select upper(fev_id) fev_id, upper(fev_fcl_id) fev_fcl_id
        from &TOOLKIT._event
       where fev_active = utl_&TOOLKIT..C_TRUE
       order by fev_fcl_id, fev_id;

    c_event_template constant varchar2(200) :=
      q'~  #FCL#_#FEV# constant varchar2(30 byte) := '#FEV#';~' || utl_&TOOLKIT..C_CR;
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
    C_PKG_NAME constant varchar2(30) := '&TOOLKIT._fst';
    l_sql_text clob :=
      'create or replace package ' || C_PKG_NAME || ' as' || utl_&TOOLKIT..C_CR;
    l_chunk varchar2(200 char);
    l_end_sql varchar2(50) := 'end ' || C_PKG_NAME || ';';

    cursor status_cur is
      select upper(fst_id) fst_id, upper(fst_fcl_id) fst_fcl_id
        from &TOOLKIT._status
       where fst_active = utl_&TOOLKIT..C_TRUE
       order by fst_fcl_id, fst_id;
    c_status_template constant varchar2(200) :=
      q'~  #FCL#_#FST# constant varchar2(30 byte) := '#FST#';~' || utl_&TOOLKIT..C_CR;
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

end &TOOLKIT._admin_pkg;
/