Program FooBar;

uses
  markus3u;

Var
  Baz: Text;
  S: String ( 2 );

begin
  Assign ( Baz, 'test.dat' );
  reset ( Baz );
  readln ( Baz, S );
  writeln ( S );
  close ( Baz );
end.
