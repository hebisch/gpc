program fjf308b;

operator + (a, b : Integer) = c : Integer;
begin
  c := a;
  Dec (c, b)
end;

begin
  if 50 + 8 = 42 then WriteLn ('OK') else WriteLn ('failed ', 50 + 8)
end.
