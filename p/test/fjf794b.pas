{$W no-parentheses}

program fjf794b;

operator or_else (a, b: Integer) c: Integer;
begin
  c := 2 * a + b
end;

begin
  if 8 or_else 26 = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
