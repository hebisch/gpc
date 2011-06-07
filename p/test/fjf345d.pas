program fjf345d;

label foo;

var
  c : Integer;
  s : String (10000);

begin
  {$x+} SetLength (s, 10000); {$x-}
  FillChar (s[1], 10000, 'x');
  c := 1;
foo:
  inc (c, ord ((copy (s, 1, 1) = '') or true));
  if c <> 1000 then goto foo;
  writeln ('OK')
end.
