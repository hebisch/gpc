program foo;

type
  t = array [-1..1] of integer;

var
  m: ^t;

begin
  new (m);
  m^[0] := 1;
  if m^[0] = 1 then writeln('OK')
end.
