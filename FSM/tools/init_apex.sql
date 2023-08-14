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

select upper('&1.') install_user, upper('&2.') remote_user, pit.get_default_language default_language
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
   

-- Map parameters to replacement variables
col apex_ws new_val APEX_WS format a30
col apex_path new_val APEX_PATH format a20
col app_id new_val APP_ID format a30
col default_language new_val DEFAULT_LANGUAGE format a30

select upper('&3.') apex_ws, 
       coalesce((select application_id from apex_applications where alias = 'FSM'), &4.) app_id,
       pit.get_default_language default_language,
       case 
         when utl_apex.get_apex_version >= 23.1 then 'apex_23_1'
         when utl_apex.get_apex_version >= 20.2 then 'apex_20_2'
       end apex_path
  from dual;


define section="********************************************************************************"
define h1="*** "
define h2="**  "
define h3="*   "
define s1=".    - "

set termout on
