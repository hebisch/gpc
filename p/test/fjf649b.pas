program fjf649b;

operator >< (a, b: Integer) = c: Integer;
begin
  c := 2 * a + b
end;

begin
  if 18 >< 6 = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
