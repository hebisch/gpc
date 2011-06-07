program fjf345a;

var
  Dummy, c : Integer;
  s : String (10000);

begin
  {$x+} SetLength (s, 10000); {$x-}
  FillChar (s[1], 10000, 'x');
  for c := 1 to 1000 do
    if copy (s, 1, 1) = '' then Dummy := 1;
  writeln ('OK')
end.
