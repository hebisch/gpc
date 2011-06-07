program fjf524g;

type
  t = ' ' .. '@';
  s = String (10);

function x: s;
var
  a: t = '!';
begin
  Return a
end;

begin
  if x = '!' then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
