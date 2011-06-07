program fjf228a;

procedure foo (const v : Real);
begin
  if v = 42 then writeln ('OK') else writeln ('failed ', v)
end;

begin
  foo (42)
end.
