{$W-}

program fjf745j;

var
  a: array [' ' .. Succ (' ')] of Integer = (42, 17);
  b: packed array [' ' .. Succ (' ')] of Integer;

begin
  Pack (a, '', b);  { sic!-( }
  if (b[''] = 42) and (b[Succ (' ')] = 17) then WriteLn ('OK') else WriteLn ('failed')
end.
