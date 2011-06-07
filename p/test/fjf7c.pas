Program fjf7c (Output);

{ FLAG --borland-pascal }

Var
  Datei: Text;
  S: String [80];

begin
  Assign ( Datei, 'fjf7c.dat' );
  rewrite ( Datei );
  writeln ( Datei, 1234567 : 3 );
  close ( Datei );
  reset ( Datei );
  readln ( Datei, S );
  close ( Datei );
  if length ( S ) = length ( '1234567' ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
