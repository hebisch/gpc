Program BO4_4b;

{ FLAG -Werror }

Type
  Foo = object
    Constructor Bar ( Const Partner: Foo );
  end { Foo };

Constructor Foo.Bar ( Const Partner: Foo );

begin { Foo.Bar }
  writeln ( 'OK' );
end { Foo.Bar };

Var
  FooBar: Foo;

begin
  FooBar.Bar ( FooBar );
end.
