Program Test;

Var
  F: File;
  Bla: LongInt;
  result: Integer;

begin
  Assign ( F, 'test.dat' );
  rewrite ( F, 1 );
  Seek ( F, 0 );
  Bla:= 42;
  BlockWrite ( F, Bla, SizeOf ( Bla ), result );
  if ( Position ( F ) = result ) and ( result = SizeOf ( Bla ) ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', FilePos ( F ), ', ', result );
  close ( F );
end.
