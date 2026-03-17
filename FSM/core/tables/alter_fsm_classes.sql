@&tools.check_has_column fsm_classes fcl_type_name "&ORA_NAME_TYPE."
comment on column fsm_classes.fcl_type_name is 'Name of the implementing SQL object type. Used to derive class ownership from ALL_TYPES.';

update fsm_classes
   set fcl_type_name = case
                         when fcl_id = 'FSM' then 'FSM_TYPE'
                         else 'FSM_' || fcl_id || '_TYPE'
                       end
 where fcl_type_name is null;

@&tools.check_has_constraint fsm_classes uq_fsm_classes_type_name "unique (fcl_type_name)"
