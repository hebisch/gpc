program fjf651d;

var
  c: Char = '9';
  i, e: Integer;

begin
  Val (c, i, e);
  if (i = 9) and (e = 0) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', i, ' ', e)
end.
