program fjf1020c;

type
  at(n:integer) = array [1..1000] of integer value [m:1 otherwise 4];

procedure p;
const
  m = 2;
var
  t: at (4);  { WRONG }
begin
end;

begin
end.
