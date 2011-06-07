program fjf974d;

type
  a = 0 .. 63 value 33;
  t = packed array [1 .. 2, 1 .. 2] of a;

var
  v: t;

begin
  if (v[1, 2] = 33) and (v[1, 2] = 33) then WriteLn ('OK') else WriteLn ('failed')
end.
