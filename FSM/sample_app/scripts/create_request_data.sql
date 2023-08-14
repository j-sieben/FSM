begin


  merge into demo_users u
  using (select 'NORMAL_USER' usr_id,
                'Normal User' usr_name,
                'User with normla user rights' usr_description,
                'USER' usr_role
           from dual
         union all
         select 'SUPERVISOR', 'Supervisor', 'User with Supervisor role', 'SUPERVISOR' from dual) v
     on (u.usr_id = v.usr_id)
   when not matched then insert(usr_id, usr_name, usr_description, usr_role)
        values(v.usr_id, v.usr_name, v.usr_description, v.usr_role);
        
  commit;
  
  
  bl_request.merge_request_type(
    p_rtp_id => 'OBJECT_PRIV',
    p_rtp_name => 'Object privilege',
    p_rtp_description => 'Request to be granted an object privilege');
    
  bl_request.merge_request_type(
    p_rtp_id => 'SYSTEM_PRIV',
    p_rtp_name => 'System privilege',
    p_rtp_description => 'Request to be granted a system privilege');
  
  commit;

  bl_request.merge_requestor(
    p_rre_id => 'JOHNDOE',
    p_rre_name => 'John Doe',
    p_rre_description => 'Developer');
    
  bl_request.merge_requestor(
    p_rre_id => 'PATABALLA',
    p_rre_name => 'Valli Pataballa',
    p_rre_description => 'Developer');
  
  commit;

end;
/