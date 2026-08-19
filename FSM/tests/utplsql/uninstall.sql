whenever sqlerror continue

begin
  delete from fsm_objects where fsm_fcl_id = 'FUT';
  fsm_admin.delete_class('FUT', true);
  pit_admin.delete_message_group('FUT', true);
  commit;
exception when others then rollback;
end;
/

drop package fsm_core_test;
drop type fsm_ut_type;
drop table fsm_ut_trace purge;

exit success
