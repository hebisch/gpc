{ fh20010127 }

program fjf481;
var
  x : Integer;
  b : Real;
begin
  x := -1;
  b := x / $100000000;
  if b * $100000000 = -1 then WriteLn ('OK') else WriteLn ('failed ', b, ' ', b * $100000000)
end.
