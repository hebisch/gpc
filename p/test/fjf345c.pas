program fjf345c;

var
  c : Integer;
  s : String (10000);

begin
  {$x+} SetLength (s, 10000); {$x-}
  FillChar (s[1], 10000, 'x');
  c := 1;
  while c <> 1000 do
    inc (c, ord ((copy (s, 1, 1) = '') or true));
  writeln ('OK')
end.
