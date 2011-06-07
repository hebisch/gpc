program FourCharCodeTest (input, output);

const
 ch1value = ord(substr('bool',1,1)[1]);

begin
  if ch1value = ord ('b') then WriteLn ('OK') else WriteLn ('failed ', ch1value, ' ', ord ('b'))
end.
