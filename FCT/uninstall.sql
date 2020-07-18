define toolkit=FSM
@init.sql &1. &2.

alter session set current_schema=&INSTALL_USER.;

@core/clean_up.sql