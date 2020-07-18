alter session set current_schema=&INSTALL_USER.;

@revoke_access.sql execute &TOOLKIT._type
@revoke_access.sql execute &TOOLKIT._pkg
@revoke_access.sql execute &TOOLKIT._fev
@revoke_access.sql execute &TOOLKIT._fst


@revoke_access.sql select &TOOLKIT._log
@revoke_access.sql select &TOOLKIT._object