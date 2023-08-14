create or replace view demo_users_vw as
select usr_id, usr_name, usr_description, usr_role
  from demo_users;
  
comment on table demo_users_vw is 'Access view for application layer';