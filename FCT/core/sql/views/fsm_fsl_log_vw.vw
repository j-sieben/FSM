create or replace force view fsm_fsl_log_vw as 
select l.fsl_fsm_id, l.fsl_log_date, d.doc_dep, replace(l.fsl_msg_text, s.fst_id, s.fst_name) fsl_msg_text,
       dre.pat, st.per_name, dre.typ, dre.textr, dre.freed, dre.dre_freeuser, dre.doc_name
  from fsm_log l
  join fsm_object o
    on l.fsl_fsm_id = o.fsm_id
  join fsm_status s
    on o.fsm_fst_id = s.fst_id
  join fsm_doc_object d
    on o.fsm_id = d.doc_id
   and instr(fsl_msg_text, s.fst_id) > 0
  join kis_cdd_doc_freigabe@kis dre
    on d.doc_name = dre.doc_name
  left join stay st
    on st.pat = dre.pat
   and can_pat_ende = 1
 where fsl_severity < 70
 order by fsl_id;

