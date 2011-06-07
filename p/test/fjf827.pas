{ No GPC bug. Just to make sure nothing breaks due to changes
  near a mysterious comment in build_indirect_ref(). }

program fjf827;

var
  t: ^Integer;
  u: ^const Integer;
  i, j: Integer;

begin
  i := 3;
  t := @i;
  u := @i;
  j := u^;
  t^ := 42;
  if (j = 3) and (u^ = 42) then WriteLn ('OK') else WriteLn ('failed')
end.
