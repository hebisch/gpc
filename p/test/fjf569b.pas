program fjf569b;

type
  t = set of 0 .. 255;

procedure Test (protected a, b: Integer);
var
  i: Integer;
  x: String (20);
begin
  x := '';
  for i := a to b do
    WriteStr (x, x, ' ', i);
  if x = ' 5 6 7' then WriteLn ('OK') else WriteLn ('failed ', x)
end;

begin
  Test (5, 7);
end.
