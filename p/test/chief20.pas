Program Chief20;

Type
  FooObj = object
    Procedure OK ( Var Foo: FooObj );
  end { FooObj };

Var
  Foo: FooObj;

Procedure FooObj.OK ( Var Foo: FooObj );

begin { FooObj.OK }
  if @Self = @Foo then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end { FooObj.OK };

begin
  Foo.OK ( Foo );
end.
