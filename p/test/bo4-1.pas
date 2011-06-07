Program BO4_1;

Type
  Foo = object
    Procedure Bar;
  end { Foo };

Var
  FooBar: Foo;
  MyFoo: ^Procedure ( Var Self: Foo );

Procedure Foo.Bar;

begin { Foo.Bar }
  writeln ( 'OK' );
end { Foo.Bar };

begin
  MyFoo:= @Foo.Bar;
  MyFoo^ ( FooBar );
end.
