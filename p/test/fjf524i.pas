program fjf524i;

type
  t = ' ' .. '@';

var
  a: t = '$';

procedure p (const s: String);
begin
  if s = '$' then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end;

begin
  p (a)
end.
