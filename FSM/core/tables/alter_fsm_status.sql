@&tools.check_has_column fsm_status fst_warn_interval "interval day to second"
comment on column fsm_status.fst_warn_interval is 'Optional lower threshold for the expected duration in this status before escalation to WARN.';

@&tools.check_has_column fsm_status fst_alert_interval "interval day to second"
comment on column fsm_status.fst_alert_interval is 'Optional upper threshold for the expected duration in this status before escalation to ALERT.';

@&tools.check_has_column fsm_status fst_escalation_basis "&ORA_NAME_TYPE. default on null 'STATUS'"
comment on column fsm_status.fst_escalation_basis is 'Determines whether elapsed time is measured from the last status change (STATUS) or the last successful event/activity (EVENT).';

@&tools.check_has_column fsm_status fst_terminal_status "&FLAG_TYPE. default &C_FALSE."
comment on column fsm_status.fst_terminal_status is 'Flag indicating whether this status is a terminal/final status of the workflow';

update fsm_status
   set fst_escalation_basis = 'STATUS'
 where fst_escalation_basis is null;

update fsm_status
   set fst_terminal_status = 'N'
 where fst_terminal_status is null;

@&tools.check_has_constraint fsm_status fst_escalation_basis_chk "check (fst_escalation_basis in ('STATUS', 'EVENT'))"
@&tools.check_has_constraint fsm_status fst_terminal_status_chk "check (fst_terminal_status in (&C_TRUE., &C_FALSE.))"
@&tools.check_has_constraint fsm_status chk_fst_escalation_interval "check ((fst_warn_interval is null and fst_alert_interval is null) or (fst_warn_interval is not null and fst_alert_interval is not null and fst_warn_interval < fst_alert_interval))"
