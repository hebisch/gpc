program fjf524h;

type
  t = ' ' .. '@';

var
  a: t = '#';
  s: String (10);

begin
  s := a;
  if s = '#' then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
