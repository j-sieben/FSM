create or replace package body bl_request
as

  /**
    Package: BL_REQUEST Body
      Business logic package for the request application

    Author::
      Juergen Sieben, ConDeS GmbH

   */

  C_OBJECT_PRIV constant fsm_request_types.rtp_id%type := 'OBJECT_PRIV';
  C_SYSTEM_PRIV constant fsm_request_types.rtp_id%type := 'SYSTEM_PRIV';
  
  /**
    Procedure: merge_request_type
      See: <BL_REQUEST.merge_request_type>
   */
  procedure merge_request_type(
    p_row in fsm_request_types_vw%rowtype)
  as
  begin
  
    pit_admin.merge_translatable_item(
      p_pti_id => p_row.rtp_id,
      p_pti_pml_name => pit.get_default_language,
      p_pti_pmg_name => 'REQ',
      p_pti_name => p_row.rtp_name,
      p_pti_description => p_row.rtp_description);
    
    merge into fsm_request_types t
    using (select p_row.rtp_id rtp_id,
                  p_row.rtp_id rtp_pti_id,
                  p_row.rtp_active rtp_active
             from dual) s
       on (t.rtp_id = s.rtp_id)
     when matched then update set
       t.rtp_active = s.rtp_active
     when not matched then insert(rtp_id, rtp_pti_id, rtp_active)
       values(s.rtp_id, s.rtp_pti_id, s.rtp_active);
    
  end merge_request_type;
  
  
  /**
    Procedure: merge_request_type
      See: <BL_REQUEST.merge_request_type>
   */
  procedure merge_request_type(
    p_rtp_id in varchar2, 
    p_rtp_name in varchar2, 
    p_rtp_description in varchar2, 
    p_rtp_active in pit_util.flag_type default pit_util.C_TRUE)
  as
    l_row fsm_request_types_vw%rowtype;
  begin
    
    l_row.rtp_id := p_rtp_id;
    l_row.rtp_name := p_rtp_name;
    l_row.rtp_description := p_rtp_description;
    l_row.rtp_active := p_rtp_active;
    
    merge_request_type(l_row);
    
  end merge_request_type;
  
  
  /**
    Procedure: delete_request_type
      See: <BL_REQUEST.delete_request_type>
   */
  procedure delete_request_type(
    p_row in fsm_request_types_vw%rowtype)
  as
  begin
    
    delete from fsm_request_types
     where rtp_id = p_row.rtp_id;
     
  end delete_request_type;
  
  
  /**
    Procedure: merge_requestor
      See: <BL_REQUEST.merge_requestor>
   */
  procedure merge_requestor(
    p_row in fsm_requestors_vw%rowtype)
  as
  begin
    
    merge into fsm_requestors t
    using (select p_row.rre_id rre_id,
                  p_row.rre_name rre_name,
                  p_row.rre_description rre_description
             from dual) s
       on (t.rre_id = s.rre_id)
     when matched then update set
       t.rre_name = s.rre_name,
       t.rre_description = s.rre_description
     when not matched then insert(rre_id, rre_name, rre_description)
       values(s.rre_id, s.rre_name, s.rre_description);
    
  end merge_requestor;
  
  
  /**
    Procedure: merge_requestor
      See: <BL_REQUEST.merge_requestor>
   */
  procedure merge_requestor(
    p_rre_id in varchar2, 
    p_rre_name in varchar2, 
    p_rre_description in varchar2)
  as
    l_row fsm_requestors_vw%rowtype;
  begin
    
    l_row.rre_id := p_rre_id;
    l_row.rre_name := p_rre_name;
    l_row.rre_description := p_rre_description;
    
    merge_requestor(l_row);
    
  end merge_requestor;
  
  
  /**
    Procedure: delete_requestor
      See: <BL_REQUEST.delete_requestor>
   */
  procedure delete_requestor(
    p_row in fsm_requestors_vw%rowtype)
  as
  begin
    
    delete from fsm_requestors
     where rre_id = p_row.rre_id;
     
  end delete_requestor;
  
  
  /**
    Procedure: merge_request
      See: <BL_REQUEST.merge_request>
   */
  procedure merge_request(
    p_row in out nocopy fsm_requests_vw%rowtype)
  as
  begin
  
    merge into fsm_requests d
    using (select p_row.fsm_id req_id,
                  p_row.req_rtp_id req_rtp_id,
                  p_row.req_rre_id req_rre_id,
                  p_row.req_text req_text
             from dual) v
       on (d.req_id = v.req_id)
     when matched then update set
          req_text = v.req_text
     when not matched then insert (req_id, req_rtp_id, req_rre_id, req_text)
          values(v.req_id, v.req_rtp_id, v.req_rre_id, v.req_text);

  end merge_request;
  
  
  /**
    Procedure: merge_request
      See: <BL_REQUEST.merge_request>
   */
  procedure merge_request(
    p_req_id in out nocopy number, 
	  p_req_rtp_id in varchar2, 
	  p_req_rre_id in varchar2, 
	  p_req_text in varchar2)
  as
    l_row fsm_requests_vw%rowtype;
  begin
    l_row.fsm_id := p_req_id;
    l_row.req_rtp_id := p_req_rtp_id;
    l_row.req_rre_id := p_req_rre_id;
    l_row.req_text := p_req_text;
    
    merge_request(l_row);
  
  end merge_request;
  
  
  /**
    Procedure: delete_request
      See: <BL_REQUEST.delete_request>
   */
  procedure delete_request(
    p_row in fsm_requests_vw%rowtype)
  as
  begin
    delete from fsm_requests
     where req_id = p_row.fsm_id;
     
  end delete_request;
  
  
  /**
    Function: get_grant_mode
      See: <BL_REQUEST.get_grant_mode>
   */
  function get_grant_mode(
    p_rtp_id in fsm_request_types.rtp_id%type,
    p_rre_id in fsm_requestors.rre_id%type)
    return pls_integer
  as
    l_mode pls_integer;
  begin
  
    case 
    when p_rtp_id = C_OBJECT_PRIV and p_rre_id = 'PATABALLA' then
      l_mode := C_GRANT_AUTOMATICALLY;
    when p_rtp_id = C_OBJECT_PRIV then
      l_mode := C_GRANT_MANUALLY;
    else
      l_mode := C_GRANT_SUPERVISOR;
    end case;
    
    return l_mode;
  end get_grant_mode;

end bl_request;
/
