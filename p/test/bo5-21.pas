Program BO5_21;

Var
  Foo: Text;
  Bar: String ( 3 ) = 'bar';

begin
  Assign ( Foo, Bar + '.dat' );
  writeln ( 'OK' );
end.
