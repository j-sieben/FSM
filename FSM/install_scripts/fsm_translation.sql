-- Translation script for Finite State Machine implementation in PL/SQL

-- Params:
-- 1.: Name of the database owner of the Toolkit
-- 2.: Target language as an oracle language name (AMERICAN | GERMAN)

define tool_dir=tools/
define core_dir=core/

@&tool_dir./init.sql

alter session set current_schema=&INSTALL_USER.;

prompt
prompt &section.
prompt &h1.FSM Translation to language &DEFAULT_LANGUAGE.
@&core_dir.load_translation.sql

prompt
prompt &section.
prompt &h1.Finalize translation

prompt &h1.Finished FSM-Translation

exit
