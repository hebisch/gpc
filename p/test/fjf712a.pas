{ FLAG -Wno-float-equal }

program fjf712a;

var
  a: Real = 2;
  b: Real = 3;
  c: Real = 5;

begin
  if (a <> c) and (a + b = c) then WriteLn ('OK') else WriteLn ('failed')
end.
