create or replace view fsm_lov_severity as
select fss_name d, fss_id r, fss_html html, fss_icon icon
  from fsm_status_severities_v;
  
comment on table fsm_lov_severity is 'LOV-View for the Request severites of the sample application';