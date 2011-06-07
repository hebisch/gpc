Program fjf226h;

{$B-}

Var
  FooBar: Boolean;


Function Foo: Integer;

begin { Foo }
  Foo:= 42;
  writeln ( 'failed (foo)' );
  Halt ( 1 )
end { Foo };


begin
  FooBar:= false and ( Foo = 42 );
  if FooBar then
    writeln ( 'failed (bar)' )
  else
    writeln ( 'OK' )
end.
