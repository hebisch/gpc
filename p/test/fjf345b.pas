program fjf345b;

var
  Dummy, c : Integer;
  s : String (10000);

begin
  {$x+} SetLength (s, 10000); {$x-}
  FillChar (s[1], 10000, 'x');
  c := 1;
  repeat
    if copy (s, 1, 1) = '' then Dummy := 1;
    inc (c)
  until c=1000;
  writeln ('OK')
end.
