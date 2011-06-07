program mir048b;
{Integer2StringBaseExt(), checking Width parameter, negative source}
uses GPC;
var Base, Width : Integer;
    s : String (4096);

begin
  for Base in [2, 3, 4, 7, 8, 9, 11, 12, 13, 16, 24, 36] do { actually, only 2, 8, 16 are special }
    for Width := 0 to 100 do
      begin
        s := Integer2StringBaseExt (-$fffff, Base, Width, False, False);
        if (Length (s) < Width) then
          begin
            WriteLn ('failed: Width (req/ret) = (', Width, '/', Length (s), ')=', s);
            Halt
          end;
        s := Integer2StringBaseExt (-$fffff, Base, Width, False, True);
        if (Length (s) < Width) then
          begin
            WriteLn ('failed: Width (req/ret) = (', Width, '/', Length (s), ')=', s);
            Halt
          end
      end;
  WriteLn ('OK')
end.
