program fjf228b;

procedure foo (const v : ShortReal);
begin
  if v = 42 then writeln ('OK') else writeln ('failed ', v)
end;

begin
  foo (42)
end.
