set verify off
set serveroutput on
set echo off
set feedback off
set lines 120
set pages 9999
whenever sqlerror exit
set termout off
col install_user new_val INSTALL_USER format a128
col remote_user new_val REMOTE_USER format a128
col default_language new_val DEFAULT_LANGUAGE format a128

select case when instr('&1.', '[') > 0 
       then substr(upper('&1.'), instr('&1.', '[') + 1, length('&1.') - instr('&1.', '[') - 1)
       else coalesce(upper('&1.'), user) end install_user, 
       case when instr('&2.', '[') > 0 
       then substr(upper('&2.'), instr('&2.', '[') + 1, length('&2.') - instr('&2.', '[') - 1)
       else coalesce(upper('&2.'), user) end remote_user, 
       pit.get_default_language default_language
  from dual;
   
col ora_name_type new_val ORA_NAME_TYPE format a128
select 'varchar2(' || data_length || ' byte)' ora_name_type
  from all_tab_columns
 where table_name = 'USER_TABLES'
   and column_name = 'TABLE_NAME';
   
-- Copy boolean value type from PIT
col FLAG_TYPE  new_val FLAG_TYPE format a128
col C_FALSE  new_val C_FALSE format a128
col C_TRUE  new_val C_TRUE format a128

select lower(data_type) || '(' ||     
         case when data_type in ('CHAR', 'VARCHAR2') then data_length || case char_used when 'B' then ' byte)' else ' char)' end
         else data_precision || ', ' || data_scale || ')'
       end FLAG_TYPE,
       case when data_type in ('CHAR', 'VARCHAR2') then dbms_assert.enquote_literal(pit_util.c_true) else to_char(pit_util.c_true) end C_TRUE, 
       case when data_type in ('CHAR', 'VARCHAR2') then dbms_assert.enquote_literal(pit_util.c_false) else to_char(pit_util.c_false) end C_FALSE
  from all_tab_columns
 where table_name = 'PARAMETER_LOCAL'
   and column_name = 'PAL_BOOLEAN_VALUE';

define section="********************************************************************************"
define h1="*** "
define h2="**  "
define h3="*   "
define s1=".    - "

set termout on
