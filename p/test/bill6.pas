program foo;
uses bill6ubar in 'bill6u.pas';

Var
  Datei: Text;
  S: String ( 10 );

begin
  writeln ( Lst, 'OK' );
  close ( Lst );
  Assign ( Datei, 'bill6.dat' );
  reset ( Datei );
  readln ( Datei, S );
  close ( Datei );
  writeln ( S );
end.
