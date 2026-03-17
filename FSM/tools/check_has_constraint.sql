column script new_value SCRIPT
column msg new_value MSG

set termout off
with has_constraint as (
       select count(*) amt
         from user_constraints
        where table_name = upper('&1.')
          and constraint_name = upper('&2.'))
select case amt when 0 then '&tools.add_constraint.sql' else 'tools/null.sql' end script,
       case amt when 0 then '&s1.Create constraint ' || upper('&2.') || ' on table ' || upper('&1.')
                     else '&s1.Constraint ' || upper('&2.') || ' on table ' || upper('&1.') || ' already exists' end msg
  from has_constraint;

set termout on
prompt &msg.
@&script. &1. &2. &3.
