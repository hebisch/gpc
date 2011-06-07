program FourCharCodeTest (input, output);

var
  s: String (10) = 'bool';

begin
  if ord(substr(s,1,1)[1]) = ord ('b') then WriteLn ('OK') else WriteLn ('failed ', ord(substr(s,1,1)[1]), ' ', ord ('b'))
end.
