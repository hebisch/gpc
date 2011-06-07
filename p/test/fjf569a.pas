program fjf569a;

type
  t = set of 0 .. 255;

procedure Test (protected s: t);
var
  i: Integer;
  x: String (20);
begin
  x := '';
  for i in s do
    WriteStr (x, x, ' ', i);
  if x = ' 5 7' then WriteLn ('OK') else WriteLn ('failed ', x)
end;

begin
  Test ([5, 7]);
end.
