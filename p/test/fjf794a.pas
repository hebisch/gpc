{$W no-parentheses}

program fjf794a;

operator and_then (a, b: Integer) c: Integer;
begin
  c := 2 * a + b
end;

begin
  if 8 and_then 26 = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
