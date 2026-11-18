begin
  delete from fsm_objects where fsm_fcl_id = 'FTX';
  fsm_admin.delete_class('FTX', true);
  pit_admin.delete_message_group('FTX', true);
  commit;
end;
/
drop type fsm_tx_type force;
drop package fsm_tx_probe;
drop table fsm_tx_trace;
