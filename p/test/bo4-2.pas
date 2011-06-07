Program BO4_2;

Type
  Foo = object
    Procedure Bar;
  end { Foo };

Procedure Foo.Bar;

begin { Foo.Bar }
  writeln ( 'OK' );
end { Foo.Bar };

Var
  FooBar: Foo;
  MyFoo: ^Procedure ( Var Self: Foo ) = @Foo.Bar;

begin
  MyFoo^ ( FooBar );
end.
