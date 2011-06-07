program fjf980b;

type
  t = packed array [1 .. 1] of Boolean;

var
  i: Integer = 1;

function f = r: t;
begin
  r[i] := True
end;

begin
  if f[1] then WriteLn ('OK') else WriteLn ('failed')
end.
