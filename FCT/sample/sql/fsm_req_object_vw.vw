create or replace view &TOOLKIT._req_object_vw as
select &TOOLKIT._id, &TOOLKIT._fcl_id, &TOOLKIT._fst_id, &TOOLKIT._fev_id, &TOOLKIT._fev_list,
       &TOOLKIT._retry_schedule, &TOOLKIT._validity,
       req_rtp_id, req_rre_id, req_text
  from &TOOLKIT._object o
  join &TOOLKIT._req_object r
    on o.&TOOLKIT._id = r.req_id;
