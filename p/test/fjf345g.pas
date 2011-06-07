program fjf345g;

label foo;

var
  c : Integer;
  s : String (10000);

begin
  SetLength (s, 10000);
  FillChar (s[1], 10000, 'x');
  c := 1;
foo:
  inc (c, ord ((copy (s, 1, 10000) = '') or true));
  if c <> 1000 then goto foo;
  writeln ('OK')
end.
