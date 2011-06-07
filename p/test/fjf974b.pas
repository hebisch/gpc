program fjf974b;

type
  a = Integer value 42;
  t = array [1 .. 2, 1 .. 2] of a;

var
  v: t;

begin
  if (v[1, 2] = 42) and (v[1, 2] = 42) then WriteLn ('OK') else WriteLn ('failed')
end.
