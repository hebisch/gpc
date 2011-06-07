program fjf1014 (Output);

var
  i: Integer value 1;
  p: array [0 .. 1] of Integer value [0: 2; 1: 3];
  a: set of 0 .. 5;

begin
  a := [p[i mod 2], 0];
  if a = [0, 3] then WriteLn ('OK') else WriteLn ('failed')
end.
