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

select upper('&1.') install_user,
       upper('&2.') remote_user
  from dual;
   
col ora_name_type new_val ORA_NAME_TYPE format a128
select 'varchar2(' || data_length || ' byte)' ora_name_type
  from all_tab_columns
 where table_name = 'USER_TABLES'
   and column_name = 'TABLE_NAME';


define INSTALL_ON_DEV = false

define section="********************************************************************************"
define h1="*** "
define h2="**  "
define h3="*   "
define s1=".    - "

set termout on
