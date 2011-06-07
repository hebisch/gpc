program fjf524e;

type
  t = ' ' .. '@';

var
  a: t = '3';
  b: Integer;

begin
  ReadStr (a, b);
  if b = 3 then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
