program fjf915m;

type
  t (n: Integer) = Integer;

var
  a: ^t;

begin
  New (a, and_then (2))  { WRONG }
end.
