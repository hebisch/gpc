program fjf524c;

type
  t = ' ' .. '@';
  u = Char;

var
  a: t = ' ';
  b: Char = ',';
  c: 'a' .. 'z' = 'x';
  d: u = '.';

begin
  if a + b + c + d = ' ,x.' then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
