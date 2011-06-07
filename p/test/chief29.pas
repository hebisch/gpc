Program Chief29;

Var
  F: File;
  x: Word attribute ( Size = 16 );
  y: Integer;

begin
  Assign ( F, 'chief29.dat' );
  rewrite ( F, 1 );
  x:= SizeOf ( y );
  y:= 42;
  BlockWrite ( F, y, x );
  close ( F );
  y:= 137;
  reset ( F, 1 );
  BlockRead ( F, y, x );
  close ( F );
  if y = 42 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' )
end.
