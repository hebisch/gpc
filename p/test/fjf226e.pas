Program fjf226e;

{$B-}

Type
  String42 = String ( 42 );


Function Foo: String42;

begin { Foo }
  Foo:= 'foo';
  writeln ( 'failed (foo)' );
  Halt ( 1 )
end { Foo };


begin
  if false and ( Foo = 'bar' ) then
    writeln ( 'failed (bar)' )
  else
    writeln ( 'OK' )
end.
