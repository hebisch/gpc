program mir048a;
{Integer2StringBaseExt(), checking Width parameter}
uses GPC;
var Base, Width : Integer;
    s : String (4096);

begin
  for Base := 2 to 36 do
    for Width := 0 to 100 do
      begin
        s := Integer2StringBaseExt ($fffff, Base, Width, False, False);
        if (Length (s) < Width) then
          begin
            WriteLn ('failed: Width (req/ret) = (', Width, '/', Length (s), ')=', s);
            Halt
          end;
        s := Integer2StringBaseExt ($fffff, Base, Width, False, True);
        if (Length (s) < Width) then
          begin
            WriteLn ('failed: Width (req/ret) = (', Width, '/', Length (s), ')=', s);
            Halt
          end
      end;
  WriteLn ('OK')
end.
