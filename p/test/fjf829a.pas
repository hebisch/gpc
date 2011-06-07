program fjf829a;

type
  t = object end;

var
  p: ^t;

begin
  Dispose (p, 42)  { WRONG }
end.
