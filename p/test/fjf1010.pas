program fjf1010 (Output);

var
  i: 0..250;
  s: set of 0 .. 250;

begin
  i := 0;
  s := [0 .. 70] * ([0 .. 80, i] >< [90]);
  if s = [0 .. 70] then WriteLn ('OK') else WriteLn ('failed')
end.
