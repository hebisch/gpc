program fjf524j;

type
  t = ' ' .. '@';

var
  a: t = '$';

procedure p (s: String);
begin
  if s = '$' then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end;

begin
  p (a)
end.
