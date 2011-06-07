program fjf1024;

var
  s: String (10) = 'foo';
  p: ^String = @s;
  b: Boolean = Trim (p^) = 'foo';

begin
  if b then WriteLn ('OK') else WriteLn ('failed')
end.
