program fjf966b;

type
  t = array [1 .. 3] of Integer;
  u = array [1 .. 2] of Char;

function a (v: t) = r: u;
begin
  r[1] := Chr (v[2]);
  r[2] := Chr (v[3])
end;

begin
  WriteLn (a (t[2: Ord ('O') otherwise Ord ('K')]))
end.
