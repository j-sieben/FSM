set define off

begin
  utl_text_admin.merge_template(
    p_uttm_name => 'EXPORT_FSM',
    p_uttm_type => 'FSM',
    p_uttm_mode => 'FRAME',
    p_uttm_text => q'{begin\CR\}' || 
q'{\CR\}' || 
q'{  fsm_admin.delete_class(\CR\}' || 
q'{    p_fcl_id => '#FCL_ID#',\CR\}' || 
q'{    p_force => true);\CR\}' || 
q'{    \CR\}' || 
q'{  fsm_admin.merge_class(\CR\}' || 
q'{    p_fcl_id => '#FCL_ID#',\CR\}' || 
q'{    p_fcl_name => '#FCL_NAME#',\CR\}' || 
q'{    p_fcl_description => q'[#FCL_DESCRIPTION#]',\CR\}' || 
q'{    p_fcl_active => #FCL_ACTIVE#);\CR\}' || 
q'{  \CR\}' || 
q'{  -- Statusgroups\CR\}' || 
q'{  #FSG_SCRIPT#\CR\}' || 
q'{  \CR\}' || 
q'{  -- Status\CR\}' || 
q'{  #FST_SCRIPT#\CR\}' || 
q'{  \CR\}' || 
q'{  -- Events\CR\}' || 
q'{  #FEV_SCRIPT#\CR\}' || 
q'{  \CR\}' || 
q'{  -- Transitions\CR\}' || 
q'{  #FTR_SCRIPT#\CR\}' || 
q'{  \CR\}' || 
q'{  commit;\CR\}' || 
q'{  \CR\}' || 
q'{  fsm_admin.create_event_package;\CR\}' || 
q'{  fsm_admin.create_status_package;\CR\}' || 
q'{end;\CR\}' || 
q'{/}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'EXPORT_FSM',
    p_uttm_type => 'FSM',
    p_uttm_mode => 'FSG',
    p_uttm_text => q'{\CR\}' || 
q'{  fsm_admin.merge_status_group(\CR\}' || 
q'{    p_fsg_id => '#FSG_ID#',\CR\}' || 
q'{    p_fsg_fcl_id => '#FSG_FCL_ID#',\CR\}' || 
q'{    p_fsg_name => '#FSG_NAME#',\CR\}' || 
q'{    p_fsg_description => q'[#FSG_DESCRIPTION#]',\CR\}' || 
q'{    p_fsg_icon_css => '#FSG_ICON_CSS#',\CR\}' || 
q'{    p_fsg_name_css => '#FSG_NAME_CSS#',\CR\}' || 
q'{    p_fsg_active => #FSG_ACTIVE#);}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'EXPORT_FSM',
    p_uttm_type => 'FSM',
    p_uttm_mode => 'FST',
    p_uttm_text => q'{\CR\}' || 
q'{  fsm_admin.merge_status(\CR\}' || 
q'{    p_fst_id => '#FST_ID#',\CR\}' || 
q'{    p_fst_fsg_id => '#FST_FSG_ID#',\CR\}' || 
q'{    p_fst_fcl_id => '#FST_FCL_ID#',\CR\}' || 
q'{    p_fst_msg_id => '#FST_MSG_ID#',\CR\}' || 
q'{    p_fst_name => '#FST_NAME#',\CR\}' || 
q'{    p_fst_description => q'[#FST_DESCRIPTION#]',\CR\}' || 
q'{    p_fst_severity => #FST_SEVERITY#,\CR\}' || 
q'{    p_fst_retries_on_error => #FST_RETRIES_ON_ERROR#,\CR\}' || 
q'{    p_fst_retry_schedule => '#FST_RETRY_SCHEDULE#',\CR\}' || 
q'{    p_fst_retry_time => #FST_RETRY_TIME#,\CR\}' || 
q'{    p_fst_icon_css => '#FST_ICON_CSS#',\CR\}' || 
q'{    p_fst_name_css => '#FST_NAME_CSS#',\CR\}' || 
q'{    p_fst_active => #FST_ACTIVE#);}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'EXPORT_FSM',
    p_uttm_type => 'FSM',
    p_uttm_mode => 'FEV',
    p_uttm_text => q'{\CR\}' || 
q'{  fsm_admin.merge_event(\CR\}' || 
q'{    p_fev_id => '#FEV_ID#',\CR\}' || 
q'{    p_fev_fcl_id => '#FEV_FCL_ID#',\CR\}' || 
q'{    p_fev_msg_id => '#FEV_MSG_ID#',\CR\}' || 
q'{    p_fev_name => '#FEV_NAME#',\CR\}' || 
q'{    p_fev_description => q'[#FEV_DESCRIPTION#]',\CR\}' || 
q'{    p_fev_raised_by_user => #FEV_RAISED_BY_USER#,\CR\}' || 
q'{    p_fev_command_label => '#FEV_COMMAND_LABEL#',\CR\}' || 
q'{    p_fev_confirm_message => q'[#FEV_CONFIRM_MESSAGE#]',\CR\}' || 
q'{    p_fev_button_icon => '#FEV_BUTTON_ICON#',\CR\}' || 
q'{    p_fev_active => #FEV_ACTIVE#);}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );

  utl_text_admin.merge_template(
    p_uttm_name => 'EXPORT_FSM',
    p_uttm_type => 'FSM',
    p_uttm_mode => 'FTR',
    p_uttm_text => q'{\CR\}' || 
q'{  fsm_admin.merge_transition(\CR\}' || 
q'{    p_ftr_fst_id => '#FTR_FST_ID#',\CR\}' || 
q'{    p_ftr_fev_id => '#FTR_FEV_ID#',\CR\}' || 
q'{    p_ftr_fcl_id => '#FTR_FCL_ID#',\CR\}' || 
q'{    p_ftr_fsc_id => '#FTR_FSC_ID#',\CR\}' || 
q'{    p_ftr_fst_list => '#FTR_FST_LIST#',\CR\}' || 
q'{    p_ftr_required_role => '#FTR_REQUIRED_ROLE#',\CR\}' || 
q'{    p_ftr_raise_automatically => #FTR_RAISE_AUTOMATICALLY#,\CR\}' || 
q'{    p_ftr_raise_on_status => #FTR_RAISE_ON_STATUS#,\CR\}' || 
q'{    p_ftr_active => #FTR_ACTIVE#);}',
    p_uttm_log_text => q'{}',
    p_uttm_log_severity => 70
  );
  commit;
end;
/
set define on
