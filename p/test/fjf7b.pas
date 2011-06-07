Program fjf7b (Output);

{ FLAG --borland-pascal }

Var
  Datei: Text;
  S: String [80];

begin
  Assign ( Datei, 'fjf7b.dat' );
  rewrite ( Datei );
  writeln ( Datei, 'abcdeOK' : 3 );
  close ( Datei );
  reset ( Datei );
  readln ( Datei, S );
  close ( Datei );
{$extended-pascal}
  if length ( S ) = length ( 'abcdeOK' ) then
    writeln ( S [ 6..7 ] )
  else
    writeln ( 'failed' );
end.
