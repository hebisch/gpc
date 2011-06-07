program fjf794d;

operator as (a, b: Integer) c: Integer;
begin
  c := 2 * a + b
end;

begin
  if 8 as 26 = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
