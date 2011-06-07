Unit markus3u;

Interface

Implementation

Var
  Bar: Text;

begin
  Assign ( Bar, 'test.dat' );
  rewrite ( Bar );
  writeln ( Bar, 'OK' );
  close ( Bar );
end.
