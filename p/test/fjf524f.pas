program fjf524f;

type
  t = ' ' .. '@';
  s = String (10);

function x: s;
var
  a: t = '!';
begin
  x := a
end;

begin
  if x = '!' then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
