program fjf615f;

type
  t (d: Integer) = Integer;

var
  s: t (42);

procedure foo (var a: Integer);
begin
end;

begin
  foo (s.d);  { WRONG }
  WriteLn ('failed')
end.
