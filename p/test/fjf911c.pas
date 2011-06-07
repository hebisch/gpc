program fjf911c;

var
  a, c: Byte;
  b: set of 1 .. 10;

begin
  a := 11;
  c := 12;
  b := [8 .. a] - [Pred (c)];
  if b = [8, 9, 10] then WriteLn ('OK') else WriteLn ('failed')
end.
