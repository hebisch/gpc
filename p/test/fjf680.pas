program fjf680;

const
  c = 'OK';

var
  v: array [1 .. 2] of Char = c;

begin
  if c + c = 'OKOK' then WriteLn (v) else WriteLn ('failed: ', c + c)
end.
