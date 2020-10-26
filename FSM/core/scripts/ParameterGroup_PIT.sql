begin
  param_admin.edit_parameter_group(
    p_pgr_id => 'PIT',
    p_pgr_description => 'Parameter for PIT',
    p_pgr_is_modifiable => true
  );

  param_admin.edit_parameter(
    p_par_id => 'PIT_FSM_DEFAULT_LOG_LEVEL'
   ,p_par_pgr_id => 'PIT'
   ,p_par_description => 'Default threeeshold for the PIT_FSM output module'
   ,p_par_integer_value => 70
  );

  commit;
end;
/
