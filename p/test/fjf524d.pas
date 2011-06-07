program fjf524d;

type
  t = ' ' .. '@';

var
  a: t = '3';
  b, c: Integer;

begin
  Val (a, b, c);
  if (c = 0) and (b = 3) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
