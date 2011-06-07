Program fjf7a;

Var
  Datei: Text;
  S: String ( 80 );

begin
  Assign ( Datei, 'fjf7a.dat' );
  rewrite ( Datei );
  writeln ( Datei, '' : 5, 'OKabcdefg' : 7 );
  close ( Datei );
  reset ( Datei );
  readln ( Datei, S );
  close ( Datei );
  if length ( S ) = 5 + 7 then
    writeln ( S [ 6..7 ] )
  else
    writeln ( 'failed' );
end.
