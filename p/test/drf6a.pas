{ BUG: overlapping case ranges are allowed in BP.
  Seems to require a change in ../stmt.c: add_case_node(), or a
  complicated code in GPC to successively eliminate duplicated
  labels. (Should give a warning. -- Frank) }

{$borland-pascal}

program drf6a;

var
  a : 0 .. 2;

begin
  a := 0;
  case a of
    1 : writeln ('failed');
    {$local W no-warnings} 0 .. 2 {$endlocal} : writeln ('OK');
  end
end.
