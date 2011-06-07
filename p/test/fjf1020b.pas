program fjf1020b;

const
  m = 1;

type
  at(n:integer) = array [1..1000] of integer value [m:1 otherwise 4];

procedure p;
const
  m = 2;
var
  t: at (4);
begin
  if (t[1] = 1) and (t[2] = 4) and (t[50] = 4) then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  p
end.
