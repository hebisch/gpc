program fjf829e;

type
  t = object end;

var
  p: ^t;

begin
  New (p, True)  { WRONG }
end.
