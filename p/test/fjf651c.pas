program fjf651c;

var
  c: Char = '9';
  i: Integer;

begin
  ReadStr (c, i);
  if i = 9 then
    WriteLn ('OK')
  else
    WriteLn ('failed ', i)
end.
