program fjf271;

var bar : array [(a, b, c)] of integer;

procedure foo (a : Integer);
begin
end;

begin
  foo (high (bar)); { WRONG }
  writeln ('failed')
end.
