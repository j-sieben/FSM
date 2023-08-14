create or replace view fsm_lov_requestor as
select rre_name d, rre_id r
  from fsm_requestors_vw;
  
comment on table fsm_lov_requestor is 'LOV-View for the Requestors of the sample application';