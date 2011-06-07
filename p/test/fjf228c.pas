program fjf228c;

procedure foo (const v : LongReal);
begin
  if v = 42 then writeln ('OK') else writeln ('failed ', v)
end;

begin
  foo (42)
end.
