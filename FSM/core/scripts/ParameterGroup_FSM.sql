/**
  Script: ParameterGroup_FSM
    Installs the session-initialization commit policy without overwriting an
    existing default or realm-local value during repeated installation.
 */
declare
  l_count number;
begin
  param_admin.edit_parameter_group(
    p_pgr_id => 'FSM',
    p_pgr_description => 'FSM runtime transaction policy',
    p_pgr_is_modifiable => true);

  select count(*) into l_count from parameter_v
   where par_id = 'AUTO_COMMIT' and par_pgr_id = 'FSM';
  if l_count = 0 then
    param_admin.edit_parameter(
      p_par_id => 'AUTO_COMMIT',
      p_par_pgr_id => 'FSM',
      p_par_description => 'Commit the complete successful FSM event chain. Read once per FSM package initialization.',
      p_par_boolean_value => true,
      -- Inherit group modifiability; PIT permits only false or null here.
      p_par_is_modifiable => null);
  end if;
  commit;
end;
/
