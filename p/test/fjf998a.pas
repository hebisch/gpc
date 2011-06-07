program fjf998a (Output);

const
  a = 'OK   ';
  b = Trim (a);
  c = Trim ('OK          ');

begin
  if EQ (b, c) then WriteLn (b) else WriteLn ('failed ', b, ', ', c)
end.
