program fjf576i;

var
  a: 10 .. 42 = 37;
  b: set of Byte;

begin
  b := [1, a];
  if b = [37, 1] then WriteLn ('OK') else WriteLn ('failed')
end.
