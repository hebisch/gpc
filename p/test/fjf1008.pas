program fjf1008 (Output);

var
  s: set of 0 .. 10;
  a, b: 0 .. 10;

begin
  a := 3;
  b := 5;
  s := [a] + [b];  { spurious warning }
  if s = [3, 5] then WriteLn ('OK') else WriteLn ('failed')
end.
