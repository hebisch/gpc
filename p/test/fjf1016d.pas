program fjf1016d (Output);

type
  i2 = Integer value 2;
  i3 = Integer value 3;
  i4 = Integer value 4;
  r = record case a: i2 of 2: (case b: i4 of 2: (e: i2); 3: (c: i4) otherwise (f: i3)) end;

var
  v: r;

begin
  if (v.a = 2) and (v.b = 4) and (v.f = 3) then WriteLn ('OK') else WriteLn ('failed')
end.
