program fjf524b;

type
  t = ' ' .. '@';

var
  a: t;

begin
  if Length (a) = 1 then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
