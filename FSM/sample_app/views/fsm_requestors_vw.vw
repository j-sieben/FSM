create or replace view fsm_requestors_vw as
select rre_id, rre_name, rre_description
  from fsm_requestors;
  
comment on table fsm_requestors_vw is 'Access view for table FSM_REQUESTORS';