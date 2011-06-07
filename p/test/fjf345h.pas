program fjf345h;

label foo;

var
  c : Integer;
  j : Integer = 10000;
  s : String (10000);

begin
  SetLength (s, 10000);
  FillChar (s[1], 10000, 'x');
  c := 1;
foo:
  inc (c, ord ((copy (s, 1, j) = '') or true));
  if c <> 1000 then goto foo;
  writeln ('OK')
end.
