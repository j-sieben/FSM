create or replace force view &TOOLKIT._next_commands_vw as 
with user_roles as 
       (select item_id name
          from user_grants
         where user_id = (select auth_user.get_current_user_id from dual)
           and item_category in ('USER_MODULE', 'ADMIN_MODULE')),
       next_events as
       (select &TOOLKIT._id, fev_id, fev_command, fev_description, fse_required_role, fev_button_highlight, fev_button_icon, fev_confirm_message
          from &TOOLKIT._object &TOOLKIT.
          join &TOOLKIT._event fev
            on instr(&TOOLKIT..&TOOLKIT._fev_list, fev.fev_id) > 0
           and &TOOLKIT..&TOOLKIT._fcl_id = fev.fev_fcl_id
          join &TOOLKIT._status_2_event fse
            on &TOOLKIT..&TOOLKIT._fcl_id = fse.fse_fcl_id
           and &TOOLKIT..&TOOLKIT._fst_id = fse.fse_fst_id
           and fev.fev_id = fse.fse_fev_id
         where fev.fev_raised_by_user = 'Y'
       )
select distinct &TOOLKIT._id,
       null lvl,
       fev_command label,
       case
       when fev_confirm_message is not null then
         'javascript:apex.confirm('''|| fev_confirm_message || ''', ''' || fev_id || ''');'
       else
         'javascript:apex.submit('''|| fev_id || ''');'
       end target,
       case fev_button_highlight
       when 'Y' then 'YES' 
       else 'NO' end is_current,
       fev_button_icon image,
       null image_attrib,
       fev_description image_alt
  from next_events ev
  left join user_roles ur
    on ev.fse_required_role = ur.name
 where ev.fev_id not in ('NIL');

