Program fjf226f;

{$B-}

Type
  String42 = String ( 42 );

Var
  FooBar: Boolean;


Function Foo: String42;

begin { Foo }
  Foo:= 'foo';
  writeln ( 'failed (foo)' );
  Halt ( 1 )
end { Foo };


begin
  FooBar:= false and ( Foo = 'bar' );
  if FooBar then
    writeln ( 'failed (bar)' )
  else
    writeln ( 'OK' )
end.
