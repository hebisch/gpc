program fjf974a;

type
  a = Integer value 42;
  t = array [1 .. 2] of a;

var
  v: t;

begin
  if (v[1] = 42) and (v[2] = 42) then WriteLn ('OK') else WriteLn ('failed ', v[1], ' ', v[2])
end.
