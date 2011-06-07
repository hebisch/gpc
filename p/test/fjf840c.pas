program fjf840c;

type
  u = array [1 .. 2] of Integer;

function g = r: u;
begin
  r[1] := Ord ('K');
  r[2] := Ord ('X')
end;

begin
  g[1] := 42  { WRONG }
end.
