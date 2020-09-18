alter session set current_schema=&INSTALL_USER.;

@grant_access.sql execute &TOOLKIT._type
@grant_access.sql execute &TOOLKIT._pkg
@grant_access.sql execute &TOOLKIT._fev
@grant_access.sql execute &TOOLKIT._fst
@grant_access.sql execute &TOOLKIT._admin_pkg


@grant_access.sql read &TOOLKIT._log
@grant_access.sql read &TOOLKIT._object
@grant_access.sql "select, references" &TOOLKIT._object
