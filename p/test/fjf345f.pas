program fjf345f;

var
  c : Integer;
  s : String (10000);

begin
  {$x+} SetLength (s, 10000); {$x-}
  FillChar (s[1], 10000, 'x');
  for c := 1 to 1000 do
    if (c > 10) and (Copy (s, 1, 10000) = '') then WriteLn (c);
  WriteLn ('OK')
end.
