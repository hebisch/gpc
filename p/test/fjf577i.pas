program fjf577i;

var
  a: 10 .. 42 = 37;
  b: set of Byte;

begin
  b := [1 .. a, 38];
  if b = [1 .. 38] then WriteLn ('OK') else WriteLn ('failed')
end.
