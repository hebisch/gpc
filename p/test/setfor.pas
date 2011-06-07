Program SetFor ( Output );

Var
  abOcKde: packed array [ 1..7 ] of Char value 'abOcKde';
  i: Integer;

begin
  {$local W-} for i in [ ] do {$endlocal}
    writeln ( 'failed' );
  for i in [ 3, 5 ] do
    write ( abOcKde [ i ] );
  writeln;
end.
