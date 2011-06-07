program fjf569f;

type
  t = set of 0 .. 255;

procedure Test (protected s: t);
var
  i: Integer;
  x: String (20);
  s2: type of s;
begin
  x := '';
  s2 := s - [7];
  for i in s2 do
    WriteStr (x, x, ' ', i);
  if x = ' 5 9' then WriteLn ('OK') else WriteLn ('failed ', x)
end;

begin
  Test ([5, 7, 9]);
end.
