Program Sets4;

Type
  Metasyntactical = ( Foo, Bar, Baz );

Var
  FooBar: set of Foo..Bar;
  BazBaz: set of Metasyntactical;

begin
  BazBaz:= FooBar;
  writeln ( 'OK' );
end.
