program fjf1020a;

type
  at(n:integer) = array [1..1000] of integer value [n:1 otherwise 0];

var
  t: at (4);  { WRONG }

begin
end.
