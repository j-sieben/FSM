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


  /**
    Function: class_has_active_transitions
      Checks whether a class/subclass configuration has active transitions and
      therefore requires metadata validation.

    Parameters:
      p_fcl_id - ID of the class to inspect
      p_fsc_id - ID of the subclass to inspect

    Returns:
      TRUE if active transitions exist for the given class/subclass
   */
  function class_has_active_transitions(
    p_fcl_id in fsm_classes.fcl_id%type,
    p_fsc_id in fsm_objects_v.fsm_fsc_id%type)
    return boolean
  as
    l_count pls_integer;
  begin
    select count(*)
      into l_count
      from fsm_transitions
     where ftr_fcl_id = p_fcl_id
       and ftr_fsc_id = p_fsc_id
       and ftr_active = pit_util.C_TRUE;

    return l_count > 0;
  end class_has_active_transitions;


  /**
    Procedure: check_metadata_if_needed
      Triggers metadata validation only if the class/subclass configuration
      already contains active transitions.

    Parameters:
      p_fcl_id - ID of the class to inspect
      p_fsc_id - ID of the subclass to inspect
   */
  procedure check_metadata_if_needed(
    p_fcl_id in fsm_classes.fcl_id%type,
    p_fsc_id in fsm_sub_classes.fsc_id%type default 'MASTER')
  as
  begin
    if class_has_active_transitions(p_fcl_id, p_fsc_id) then
      check_metadata(p_fcl_id, p_fsc_id);
    end if;
  end check_metadata_if_needed;


  /**
    Procedure: check_metadata_for_class
      Triggers metadata validation for all subclasses of a class that already
      contain active transitions.

    Parameters:
      p_fcl_id - ID of the class to inspect
   */
  procedure check_metadata_for_class(
    p_fcl_id in fsm_classes.fcl_id%type)
  as
  begin
    for rec in (
      select distinct ftr_fsc_id
        from fsm_transitions
       where ftr_fcl_id = p_fcl_id
         and ftr_active = pit_util.C_TRUE)
    loop
      check_metadata_if_needed(p_fcl_id, rec.ftr_fsc_id);
    end loop;
  end check_metadata_for_class;


  /**
    Procedure: report_multiple_auto_events
      Reports invalid metadata if more than one automatic event is defined for the
      same status/subclass/result-status combination.

    Parameters:
      p_fcl_id - ID of the class to inspect
      p_fsc_id - ID of the subclass to inspect
   */
  procedure report_multiple_auto_events(
    p_fcl_id in fsm_objects_v.fsm_fcl_id%type,
    p_fsc_id in fsm_objects_v.fsm_fsc_id%type)
  as
    cursor multiple_auto_cur(
      p_fcl_id in fsm_objects_v.fsm_fcl_id%type,
      p_fsc_id in fsm_objects_v.fsm_fsc_id%type) 
    is
      select ftr_fst_id, ftr_fsc_id, ftr_raise_on_status
        from (
          select ftr_fst_id, ftr_fsc_id, ftr_raise_on_status
            from fsm_transitions
           where ftr_fcl_id = p_fcl_id
             and ftr_fsc_id = p_fsc_id
             and ftr_active = pit_util.C_TRUE
             and ftr_raise_automatically = pit_util.C_TRUE
           group by ftr_fst_id, ftr_fsc_id, ftr_raise_on_status
          having count(distinct ftr_fev_id) > 1);
  begin
    for finding in multiple_auto_cur(p_fcl_id, p_fsc_id) loop
      pit.raise_error(
        msg.FSM_MULTIPLE_AUTO_EVENTS,
        msg_args(finding.ftr_fst_id, finding.ftr_fsc_id, to_char(finding.ftr_raise_on_status)));
    end loop;
  end report_multiple_auto_events;


  /**
    Procedure: check_initial_statuses
      Ensures that exactly one initial status exists for the given class/subclass
      configuration.

    Parameters:
      p_fcl_id - ID of the class to inspect
      p_fsc_id - ID of the subclass to inspect
   */
  procedure check_initial_statuses(
    p_fcl_id in fsm_objects_v.fsm_fcl_id%type,
    p_fsc_id in fsm_objects_v.fsm_fsc_id%type)
  as
    l_count binary_integer;
  begin
    select count(distinct fst_id)
      into l_count
      from fsm_transitions
      join fsm_status
        on ftr_fst_id = fst_id
     where ftr_active = pit_util.C_TRUE
       and fst_active = pit_util.C_TRUE
       and fst_initial_status = (select pit_util.C_TRUE from dual)
       and ftr_fcl_id = p_fcl_id
       and ftr_fsc_id = p_fsc_id;
    
    pit.assert(l_count > 0, msg.FSM_NO_INITIAL_STATUS);
    pit.assert(l_count = 1, msg.FSM_TOO_MANY_INITIALS);
  end check_initial_statuses;


  /**
    Procedure: report_unreachable_statuses
      Reports active statuses that cannot be reached from the configured initial
      status within the given class/subclass configuration.

    Parameters:
      p_fcl_id - ID of the class to inspect
      p_fsc_id - ID of the subclass to inspect
   */
  procedure report_unreachable_statuses(
    p_fcl_id in fsm_objects_v.fsm_fcl_id%type,
    p_fsc_id in fsm_objects_v.fsm_fsc_id%type)
  as
    cursor unreachable_status_cur(
      p_fcl_id in fsm_objects_v.fsm_fcl_id%type,
      p_fsc_id in fsm_objects_v.fsm_fsc_id%type)
    is
      with active_statuses as (
             select fst_id
               from fsm_status
              where fst_fcl_id = p_fcl_id
                and fst_active = pit_util.C_TRUE),
           active_transitions as (
             select ftr_fst_id, ftr_fst_list
               from fsm_transitions
              where ftr_fcl_id = p_fcl_id
                and ftr_fsc_id = p_fsc_id
                and ftr_active = pit_util.C_TRUE),
           edges as (
             select distinct ftr_fst_id source_status,
                    regexp_substr(ftr_fst_list, '[^:]+', 1, level) target_status
               from active_transitions at
            connect by regexp_substr(ftr_fst_list, '[^:]+', 1, level) is not null
                    and prior ftr_fst_id = ftr_fst_id
                    and prior ftr_fst_list = ftr_fst_list),
           initials as (
             select fst_id
               from fsm_status
              where fst_fcl_id = p_fcl_id
                and fst_active = pit_util.C_TRUE
                and fst_initial_status = pit_util.C_TRUE),
           reachable_statuses as (
             select fst_id status_id
               from initials
             union
             select distinct target_status
               from edges
              start with source_status in (
                    select fst_id
                      from initials)
            connect by nocycle prior target_status = source_status)
      select fst_id
        from (select fst_id
                from active_statuses
              minus
              select status_id
                from reachable_statuses);
  begin
    if p_fsc_id = 'MASTER' then
      -- Only global class must be able to reach any status,
      -- subclasses may address a subset of statuses only
      for finding in unreachable_status_cur(p_fcl_id, p_fsc_id) loop
        pit.raise_error(
          msg.FSM_UNREACHABLE_STATUS,
          msg_args(finding.fst_id, p_fcl_id));
      end loop;
    end if;
  end report_unreachable_statuses;


  /**
    Procedure: report_dead_ends
      Reports reachable, non-terminal statuses that do not have an active outgoing
      transition within the given class/subclass configuration.

    Parameters:
      p_fcl_id - ID of the class to inspect
      p_fsc_id - ID of the subclass to inspect
   */
  procedure report_dead_ends(
    p_fcl_id in fsm_objects_v.fsm_fcl_id%type,
    p_fsc_id in fsm_objects_v.fsm_fsc_id%type)
  as
    cursor dead_ends_cur(
      p_fcl_id in fsm_objects_v.fsm_fcl_id%type,
      p_fsc_id in fsm_objects_v.fsm_fsc_id%type)
    is
      with active_transitions as (
             select ftr_fst_id, ftr_fst_list
               from fsm_transitions
              where ftr_fcl_id = p_fcl_id
                and ftr_fsc_id = p_fsc_id
                and ftr_active = pit_util.C_TRUE),
           edges as (
             select distinct ftr_fst_id source_status,
                    regexp_substr(ftr_fst_list, '[^:]+', 1, level) target_status
               from active_transitions
             connect by regexp_substr(ftr_fst_list, '[^:]+', 1, level) is not null
                    and prior sys_guid() is not null
                    and prior ftr_fst_id = ftr_fst_id
                    and prior ftr_fst_list = ftr_fst_list),
           initials as (
             select fst_id
               from fsm_status
              where fst_fcl_id = p_fcl_id
                and fst_active = pit_util.C_TRUE
                and fst_initial_status = pit_util.C_TRUE),
           reachable_statuses as (
             select fst_id
               from initials
             union
             select distinct target_status
               from edges
              start with source_status in (
                    select fst_id
                      from initials)
            connect by nocycle prior target_status = source_status)
      select rs.fst_id
        from reachable_statuses rs
        join fsm_status st
          on st.fst_id = rs.fst_id
         and st.fst_fcl_id = p_fcl_id
       where not exists (
             select 1
               from active_transitions at
              where at.ftr_fst_id = rs.fst_id)
         and st.fst_terminal_status = pit_util.C_FALSE;
  begin
    for finding in dead_ends_cur(p_fcl_id, p_fsc_id) loop
      pit.raise_error(
        msg.FSM_DEAD_END_STATUS,
        msg_args(finding.fst_id, p_fcl_id));
    end loop;
  end report_dead_ends;


  /**
    Procedure: create_constant_package_for
      Generates and compiles a constant package from the configured UTL_TEXT
      templates. Depending on the requested package name, constants for all
      active events or all active statuses are emitted.

    Parameters:
      p_pkg_name - Name of the package to generate, supported values are
                   FSM_FEV and FSM_FST
   */
  procedure create_constant_package_for(
    p_pkg_name in varchar2
  )
  as
    l_sql_text clob;
  begin
    with templates as (
           select uttm_text template, uttm_mode
             from utl_text_templates
            where uttm_name = 'FSM_PACKAGE'
              and uttm_type = 'FSM')
    select case p_pkg_name
             when 'FSM_FEV' then
               utl_text.generate_text(cursor(
                 select frame.template, p_pkg_name pkg_name,
                        utl_text.generate_text(cursor(
                          select template,
                                 upper(fev_fcl_id) fcl_id,
                                 upper(fev_id) item_id
                            from fsm_events
                           cross join templates
                           where uttm_mode = 'CONST'
                             and fev_active = pit_util.C_TRUE
                           order by fev_fcl_id, fev_id
                        ), fsm.C_CR) constants
                   from templates frame
                  where frame.uttm_mode = 'FRAME')
               )
             when 'FSM_FST' then
               utl_text.generate_text(cursor(
                 select frame.template, p_pkg_name pkg_name,
                        utl_text.generate_text(cursor(
                          select template,
                                 upper(fst_fcl_id) fcl_id,
                                 upper(fst_id) item_id
                            from fsm_status
                           cross join templates
                           where uttm_mode = 'CONST'
                             and fst_active = pit_util.C_TRUE
                           order by fst_fcl_id, fst_id
                        ), fsm.C_CR) constants
                   from templates frame
                  where frame.uttm_mode = 'FRAME')
               )
           end
      into l_sql_text
      from dual;

    execute immediate l_sql_text;
  end create_constant_package_for;
    
  
  /* INTERFACE */    
  /**
    Procedure: merge_class
      See <FSM_ADMIN.merge_class>
   */
  procedure merge_class(
    p_fcl_id in fsm_classes_v.fcl_id%type,
    p_fcl_type_name in fsm_classes_v.fcl_type_name%type,
    p_fcl_name in fsm_classes_v.fcl_name%type,
    p_fcl_description in fsm_classes_v.fcl_description%type,
    p_fcl_active in boolean default true)
  as
    l_active pit_util.flag_type;
    l_pti_id pit_util.ora_name_type;
  begin
    l_active := pit_util.to_bool(p_fcl_active);
    l_pti_id := C_PTI_CLASS_PREFIX || p_fcl_id;
    
    if p_fcl_id = C_STD_FCL then
      pit.assert(upper(p_fcl_type_name) = 'FSM_TYPE');
    end if;
    
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
                  upper(p_fcl_type_name) fcl_type_name,
                  l_active fcl_active
             from dual) s
       on (t.fcl_id = s.fcl_id)
     when matched then update set
          fcl_type_name = s.fcl_type_name,
          fcl_active = s.fcl_active
     when not matched then insert (fcl_id, fcl_pti_id, fcl_type_name, fcl_active)
          values (s.fcl_id, s.fcl_pti_id, s.fcl_type_name, s.fcl_active);
          
    create_sub_class(p_fcl_id);
          
  end merge_class;
  
  procedure merge_class(
    p_row in fsm_classes_v%rowtype)
  as
  begin
    merge_class(
      p_fcl_id => p_row.fcl_id,
      p_fcl_type_name => p_row.fcl_type_name,
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
    l_active := pit_util.to_bool(p_fsc_active);
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

    check_metadata_if_needed(p_fsc_fcl_id, p_fsc_id);
          
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

    check_metadata_if_needed(p_fsc_fcl_id, p_fsc_id);
      
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
    l_active := pit_util.to_bool(p_fsg_active);
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
    p_fst_warn_interval in fsm_status_v.fst_warn_interval%type default null,
    p_fst_alert_interval in fsm_status_v.fst_alert_interval%type default null,
    p_fst_escalation_basis in fsm_status_v.fst_escalation_basis%type default 'STATUS',
    p_fst_icon_css in fsm_status_v.fst_icon_css%type default null,
    p_fst_name_css in fsm_status_v.fst_name_css%type default null,
    p_fst_initial_status in boolean default false,
    p_fst_terminal_status in boolean default false,
    p_fst_active in boolean default true)
  as
    l_initial_status pit_util.flag_type;
    l_terminal_status pit_util.flag_type;
    l_active pit_util.flag_type;
    l_pti_id pit_util.ora_name_type;
  begin
    l_initial_status := pit_util.to_bool(p_fst_initial_status);
    l_terminal_status := pit_util.to_bool(p_fst_terminal_status);
    l_active := pit_util.to_bool(p_fst_active);
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
                  p_fst_warn_interval fst_warn_interval,
                  p_fst_alert_interval fst_alert_interval,
                  upper(coalesce(p_fst_escalation_basis, 'STATUS')) fst_escalation_basis,
                  p_fst_icon_css fst_icon_css,
                  p_fst_name_css fst_name_css,
                  l_initial_status fst_initial_status,
                  l_terminal_status fst_terminal_status,
                  l_active fst_active
             from dual) s
       on (t.fst_id = s.fst_id and t.fst_fcl_id = s.fst_fcl_id)
     when matched then update set
          t.fst_fsg_id = s.fst_fsg_id,
          t.fst_msg_id = s.fst_msg_id,
          t.fst_retries_on_error = s.fst_retries_on_error,
          t.fst_retry_schedule = s.fst_retry_schedule,
          t.fst_retry_time = s.fst_retry_time,
          t.fst_warn_interval = s.fst_warn_interval,
          t.fst_alert_interval = s.fst_alert_interval,
          t.fst_escalation_basis = s.fst_escalation_basis,
          t.fst_icon_css = s.fst_icon_css,
          t.fst_name_css = s.fst_name_css,
          t.fst_initial_status = s.fst_initial_status,
          t.fst_terminal_status = s.fst_terminal_status,
          t.fst_active = s.fst_active
     when not matched then insert
          (fst_id, fst_fcl_id, fst_fsg_id, fst_msg_id, fst_pti_id, fst_initial_status, fst_terminal_status, fst_active,
           fst_retries_on_error, fst_retry_schedule, fst_retry_time,
           fst_warn_interval, fst_alert_interval, fst_escalation_basis,
           fst_icon_css, fst_name_css)
          values
          (s.fst_id, s.fst_fcl_id, s.fst_fsg_id, s.fst_msg_id, s.fst_pti_id, s.fst_initial_status, s.fst_terminal_status, s.fst_active,
           s.fst_retries_on_error, s.fst_retry_schedule, s.fst_retry_time,
           s.fst_warn_interval, s.fst_alert_interval, s.fst_escalation_basis,
           s.fst_icon_css, s.fst_name_css);

    check_metadata_for_class(p_fst_fcl_id);
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
      p_fst_warn_interval => p_row.fst_warn_interval,
      p_fst_alert_interval => p_row.fst_alert_interval,
      p_fst_escalation_basis => p_row.fst_escalation_basis,
      p_fst_icon_css => p_row.fst_icon_css,
      p_fst_name_css => p_row.fst_name_css,
      p_fst_initial_status => pit_util.to_bool(p_row.fst_initial_status),
      p_fst_terminal_status => pit_util.to_bool(p_row.fst_terminal_status),
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

    check_metadata_for_class(p_fst_fcl_id);
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
    l_active := pit_util.to_bool(p_fev_active);    
    l_raised_by_user := pit_util.to_bool(p_fev_raised_by_user);
    l_button_highlight := pit_util.to_bool(p_fev_button_highlight);
    
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

    check_metadata_for_class(p_fev_fcl_id);
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

    check_metadata_for_class(p_fev_fcl_id);
  end delete_event;
  
  
  /**
    Procedure: merge_transition
      See <FSM_ADMIN.merge_transition>
   */
  procedure merge_transition(
    p_ftr_fst_id in fsm_transitions_v.ftr_fst_id%type,
    p_ftr_fev_id in fsm_transitions_v.ftr_fev_id%type,
    p_ftr_fcl_id in fsm_transitions_v.ftr_fcl_id%type,
    p_ftr_fsc_id in fsm_transitions_v.ftr_fsc_id%type default 'MASTER',
    p_ftr_fst_list in fsm_transitions_v.ftr_fst_list%type,
    p_ftr_raise_automatically in boolean,
    p_ftr_raise_on_status in fsm_transitions_v.ftr_raise_on_status%type default fsm.C_OK,
    p_ftr_required_role in fsm_transitions_v.ftr_required_role%type default null,
    p_ftr_active in boolean default true)
  as
    l_active pit_util.flag_type;
    l_raise_automatically pit_util.flag_type;
  begin
    l_active := pit_util.to_bool(p_ftr_active);
    l_raise_automatically := pit_util.to_bool(p_ftr_raise_automatically);
    
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

    check_metadata_if_needed(p_ftr_fcl_id, p_ftr_fsc_id);
  end delete_transition;

  /**
    Procedure: create_event_package
      See <FSM_ADMIN.create_event_package>
   */
  procedure create_event_package
  as
  begin
    create_constant_package_for('FSM_FEV');
  end create_event_package;
  
  
  /**
    Procedure: create_status_package
      See <FSM_ADMIN.create_status_package>
   */
  procedure create_status_package
  as
  begin
    create_constant_package_for('FSM_FST');
  end create_status_package;
  
  
  /**
    Procedure: check_metadata
      See <FSM_ADMIN.check_metadata>
   */
  procedure check_metadata(
    p_fcl_id in fsm_objects_v.fsm_fcl_id%type,
    p_fsc_id in fsm_objects_v.fsm_fsc_id%type)
  as
  begin
  
    check_initial_statuses(p_fcl_id, p_fsc_id);

    report_multiple_auto_events(p_fcl_id, p_fsc_id);

    report_unreachable_statuses(p_fcl_id, p_fsc_id);

    report_dead_ends(p_fcl_id, p_fsc_id);
    
  end check_metadata;
  
  
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
             select template, cls.fcl_id, cls.fcl_type_name,
                    pti.pti_name fcl_name, pti.pti_description fcl_description,
                    case cls.fcl_active when pit_util.C_TRUE then 'true' else 'false' end fcl_active,
                    utl_text.generate_text(cursor(
                      select template, fsc.fsc_id, fsc.fsc_fcl_id, pti.pti_name fsc_name, pti.pti_description fsc_description,
                             case fsc.fsc_active when pit_util.C_TRUE then 'true' else 'false' end fsc_active
                        from fsm_sub_classes fsc
                        join pit_translatable_item_v pti
                          on fsc.fsc_pti_id = pti.pti_id
                         and fsc.fsc_fcl_id = pti.pti_pmg_name
                       cross join templates
                       where uttm_mode = 'FSC'
                         and fsc.fsc_fcl_id = cls.fcl_id
                    ), C_CR) fsc_script,
                    utl_text.generate_text(cursor(
                      select template, fsg.fsg_id, fsg.fsg_fcl_id, pti.pti_name fsg_name, pti.pti_description fsg_description,
                             fsg.fsg_icon_css, fsg.fsg_name_css,
                             case fsg.fsg_active when pit_util.C_TRUE then 'true' else 'false' end fsg_active
                        from fsm_status_groups fsg
                        join pit_translatable_item_v pti
                          on fsg.fsg_pti_id = pti.pti_id
                         and fsg.fsg_fcl_id = pti.pti_pmg_name
                       cross join templates
                       where uttm_mode = 'FSG'
                         and fsg.fsg_fcl_id = cls.fcl_id
                    ), C_CR) fsg_script,
                    utl_text.generate_text(cursor(
                      select template, fst.fst_id, fst.fst_fcl_id, fst.fst_fsg_id, fst.fst_msg_id, fst.fst_pti_id,
                             pti.pti_name fst_name, pti.pti_description fst_description,
                             fst.fst_retries_on_error, msg.pms_pse_id fst_severity, fst.fst_retry_schedule,
                             coalesce(to_char(fst.fst_retry_time), 'null') fst_retry_time,
                             case
                               when fst.fst_warn_interval is not null then 
                                    to_char(extract(day from fst.fst_warn_interval))
                                    || ' '
                                    || lpad(to_char(extract(hour from fst.fst_warn_interval)), 2, '0')
                                    || ':'
                                    || lpad(to_char(extract(minute from fst.fst_warn_interval)), 2, '0')
                                    || ':'
                                    || lpad(to_char(trunc(extract(second from fst.fst_warn_interval))), 2, '0')
                             end fst_warn_interval,
                             case
                               when fst.fst_alert_interval is not null then
                                    to_char(extract(day from fst.fst_alert_interval))
                                    || ' '
                                    || lpad(to_char(extract(hour from fst.fst_alert_interval)), 2, '0')
                                    || ':'
                                    || lpad(to_char(extract(minute from fst.fst_alert_interval)), 2, '0')
                                    || ':'
                                    || lpad(to_char(trunc(extract(second from fst.fst_alert_interval))), 2, '0')
                             end fst_alert_interval,
                             fst.fst_escalation_basis,
                             fst.fst_icon_css, fst.fst_name_css,
                             case fst.fst_initial_status when pit_util.C_TRUE then 'true' else 'false' end fst_initial_status,
                             case fst.fst_terminal_status when pit_util.C_TRUE then 'true' else 'false' end fst_terminal_status,
                             case fst.fst_active when pit_util.C_TRUE then 'true' else 'false' end fst_active
                        from fsm_status fst
                        join pit_message_v msg
                          on fst.fst_msg_id = msg.pms_name
                         and fst.fst_fcl_id = msg.pms_pmg_name
                        join pit_translatable_item_v pti
                          on fst.fst_pti_id = pti.pti_id
                         and fst.fst_fcl_id = pti.pti_pmg_name
                       cross join templates
                       where uttm_mode = 'FST'
                         and fst.fst_fcl_id = cls.fcl_id
                    ), C_CR) fst_script,
                    utl_text.generate_text(cursor(
                      select template, fev.fev_id, fev.fev_fcl_id, fev.fev_msg_id, pti.pti_name fev_name, pti.pti_description fev_description,
                             case fev.fev_raised_by_user when pit_util.C_TRUE then 'true' else 'false' end fev_raised_by_user,
                             pti.pti_display_name fev_command_label, fev.fev_button_highlight, fev.fev_confirm_message, fev.fev_button_icon,
                             case fev.fev_active when pit_util.C_TRUE then 'true' else 'false' end fev_active
                        from fsm_events fev
                        join pit_translatable_item_v pti
                          on fev.fev_pti_id = pti.pti_id
                         and fev.fev_fcl_id = pti.pti_pmg_name
                       cross join templates
                       where uttm_mode = 'FEV'
                         and fev.fev_fcl_id = cls.fcl_id
                    ), C_CR) fev_script,
                    utl_text.generate_text(cursor(
                      select template, ftr.ftr_fst_id, ftr.ftr_fev_id, ftr.ftr_fcl_id, ftr.ftr_fsc_id, ftr.ftr_fst_list, ftr.ftr_required_role, ftr.ftr_raise_on_status,
                             case ftr.ftr_raise_automatically when pit_util.C_TRUE then 'true' else 'false' end ftr_raise_automatically,
                             case ftr.ftr_active when pit_util.C_TRUE then 'true' else 'false' end ftr_active
                        from fsm_transitions ftr
                       cross join templates
                       where uttm_mode = 'FTR'
                         and ftr.ftr_fcl_id = cls.fcl_id
                    ), C_CR) ftr_script
               from fsm_classes cls
               join pit_translatable_item_v pti
                 on cls.fcl_pti_id = pti.pti_id
                and cls.fcl_id = pti.pti_pmg_name
              cross join templates
              where uttm_mode = 'FRAME'
                and cls.fcl_id = p_fcl_id
           )) resultat
      into l_script
      from dual;
      
    return l_script;
  end export_class;


  function get_class_diagram(
    p_fcl_id in fsm_classes_v.fcl_id%type,
    p_fsc_id in fsm_sub_classes_v.fsc_id%type default 'MASTER')
    return clob
  as
    l_diagram clob;
    l_has_edges pls_integer;
    C_CR constant pit_util.flag_type := chr(10);
  begin
    select count(*)
      into l_has_edges
      from bl_fsm_edges
     where fcl_id = p_fcl_id
       and fsc_id = p_fsc_id;

    if l_has_edges > 0 then
      with templates as (
            select uttm_text template, uttm_mode
              from utl_text_templates
              where uttm_name = 'FSM_MERMAID'
                and uttm_type = 'FSM')
      select utl_text.generate_text(cursor(
              select frame.template,
                      utl_text.generate_text(cursor(
                        select template,
                                's_' || lower(status_id) node_id,
                                status_id,
                                replace(replace(replace(coalesce(status_name, ''), '"', '\"'), chr(10), ' '), chr(13), ' ') status_name,
                                case
                                  when is_initial = pit_util.C_TRUE then 'initial'
                                end initial_class,
                                case
                                  when is_terminal = pit_util.C_TRUE then 'terminal'
                                end terminal_class
                          from (
                            select fst.fst_id status_id,
                                    pti.pti_name status_name,
                                    fst.fst_initial_status is_initial,
                                    fst.fst_terminal_status is_terminal
                              from fsm_status fst
                              join pit_translatable_item_v pti
                                on fst.fst_pti_id = pti.pti_id
                                and fst.fst_fcl_id = pti.pti_pmg_name
                              where fst.fst_fcl_id = p_fcl_id
                                and fst.fst_active = pit_util.C_TRUE
                                and exists (
                                      select 1
                                        from fsm_transitions ftr
                                      where ftr.ftr_fcl_id = p_fcl_id
                                        and ftr.ftr_fsc_id = p_fsc_id
                                        and ftr.ftr_active = pit_util.C_TRUE
                                        and (    ftr.ftr_fst_id = fst.fst_id
                                              or instr(':' || ftr.ftr_fst_list || ':', ':' || fst.fst_id || ':') > 0))
                          )
                          cross join templates
                          where uttm_mode = case
                                              when is_initial = pit_util.C_TRUE
                                                or is_terminal = pit_util.C_TRUE
                                              then 'CLASS'
                                              else 'NODE'
                                            end
                          order by status_id
                      ), C_CR, p_enable_second_level => pit_util.C_TRUE)
                      || utl_text.generate_text(cursor(
                        select template,
                                's_' || lower(source_status_id) source_node_id,
                                's_' || lower(target_status_id) target_node_id,
                                replace(replace(replace(nvl(
                                  event_id || ': ' || event_name
                                  || case when raise_automatically = pit_util.C_TRUE then ' - auto' end
                                  || case when raise_on_status = fsm.C_ERROR then ' - error' end
                                , ''), '"', '\"'), chr(10), ' '), chr(13), ' ') edge_label
                          from bl_fsm_edges
                          cross join templates
                          where fcl_id = p_fcl_id
                            and fsc_id = p_fsc_id
                            and uttm_mode = 'EDGE'
                          order by source_status_id, event_id, target_status_id
                      ), C_CR, p_enable_second_level => pit_util.C_TRUE) content
                from templates frame
                where frame.uttm_mode = 'FRAME'
            ))
        into l_diagram
        from dual;
    end if;

    return l_diagram;
  end get_class_diagram;
  

end fsm_admin;
/
