create or replace package body util_&TOOLKIT.
as

  /* INTERFACE */
  procedure bulk_replace(
    p_value in out nocopy varchar2,
    p_replacement char_table)
  as
  begin
	pit.enter_detailed;
    for l_replacement_count in 1 .. p_replacement.count
    loop
      if (l_replacement_count mod 2 = 1) then
        p_value := replace(
                     p_value,
                     p_replacement(l_replacement_count),
                     p_replacement(l_replacement_count + 1));
      end if;
    end loop;
	pit.leave_detailed;
  end bulk_replace;


  function bulk_replace(
    p_value in varchar2,
    p_replacement char_table)
    return varchar2
  as
    l_val max_char;
  begin
	pit.enter_detailed;
    l_val := p_value;
    bulk_replace(l_val, p_replacement);
	pit.leave_detailed;
    return l_val;
  end bulk_replace;

end util_&TOOLKIT.;
/