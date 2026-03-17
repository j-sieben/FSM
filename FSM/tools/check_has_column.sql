column script new_value SCRIPT
column msg new_value MSG
column created new_value CREATED

set termout off
with has_column as (
       select count(*) amt
         from user_tab_cols
        where table_name = upper('&1.')
          and column_name = upper('&2.'))
select case amt when 0 then '&tools.add_column.sql' else 'tools/null.sql' end script,
       case amt when 0 then '&s1.Create column ' || upper('&2.') || ' on table ' || upper('&1.')
                     else '&s1.Column ' || upper('&2.') || ' on table ' || upper('&1.') || ' already exists' end msg,
       case amt when 0 then 'Y' else 'N' end created
  from has_column;

set termout on
prompt &msg.
@&script. &1. &2. &3.
