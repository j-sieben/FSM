define tool_dir=tools/

prompt
prompt &h2.Removing registration of FSM objects at &REMOTE_USER.

prompt &h3.Drop synonyms
@&tool_dir.drop_object.sql my_synonym