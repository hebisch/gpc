Program BO4_3;

Type
  Foo = object
    Procedure Bar ( Const Partner: Foo );
  end { Foo };

Procedure Foo.Bar ( Const Partner: Foo );

begin { Foo.Bar }
  writeln ( 'OK' );
end { Foo.Bar };

Var
  FooBar: Foo;

begin
  FooBar.Bar ( FooBar );
end.
