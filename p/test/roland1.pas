Program Roland1;

Type
  D = record
    S: String [ 20 ];
  end { D };

Var
  Dat: File of D;

begin
  rewrite ( Dat, 'roland1.dat' );
  with Dat^ do
    S := 'OK';
  put ( Dat );
  close ( Dat );
  reset ( Dat, 'roland1.dat' );
  { get ( Dat ); -- This is wrong: `Get' would read in the *next* record! -- Frank }
  if Dat^.S.capacity = 20 then
    writeln ( Dat^.S )
  else
    writeln ( 'failed: ', Dat^.S.capacity );
  close ( Dat );
end.
