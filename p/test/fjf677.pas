program fjf677;

const
  s = 'ab';
  t = s + s;

begin
  if t = 'abab' then WriteLn ('OK') else WriteLn ('failed')
end.
