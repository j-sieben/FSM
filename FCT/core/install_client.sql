alter session set current_schema=&INSTALL_USER.;

@grant_access.sql execute &TOOLKIT._type
@grant_access.sql execute &TOOLKIT._pkg
@grant_access.sql execute &TOOLKIT._fev
@grant_access.sql execute &TOOLKIT._fst


@grant_access.sql select &TOOLKIT._log
@grant_access.sql select &TOOLKIT._object