Program Files1;

Var
  F: file of Integer;
  n: Integer;

begin
  Assign ( F, 'test.dat' );
  rewrite ( F );
  for n:= 0 to 5 do
    write ( F, n );
  close ( F );
  reset ( F );
  Seek ( F, 4 );
  read ( F, n );
  if n = 4 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
  close ( F );
end.
