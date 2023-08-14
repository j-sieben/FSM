create or replace view fsm_lov_demo_user as
select usr_name d, usr_id r
  from demo_users_vw;
  
comment on table fsm_lov_demo_user is 'LOV-View for the demo users of the sample application';