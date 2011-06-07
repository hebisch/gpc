program fjf1104c (Output);

type
  s1 = set of 1 .. 100;
  s2 = set of 0 .. 200;

function f: s1;
begin
  f := [1 .. 10, 20, 40]
end;

var
  s: s2 = f;

begin
  if s = [20, 1 .. 10, 40] then WriteLn ('OK') else WriteLn ('failed')
end.
