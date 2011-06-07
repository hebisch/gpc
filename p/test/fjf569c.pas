program fjf569c;

type
  t = set of 0 .. 255;

const
  s: t = [5, 7];

var
  i: Integer;
  x: String (20);
begin
  x := '';
  for i in s do
    WriteStr (x, x, ' ', i);
  if x = ' 5 7' then WriteLn ('OK') else WriteLn ('failed ', x)
end.
