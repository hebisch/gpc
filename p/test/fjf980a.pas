program fjf980a;

type
  t = packed array [1 .. 1] of Boolean;

function f = r: t;
begin
  r[1] := True
end;

begin
  if f[1] then WriteLn ('OK') else WriteLn ('failed')
end.
