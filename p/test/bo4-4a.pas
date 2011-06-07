Program BO4_4a;

{ FLAG -Werror }

Type
  Foo = object
    Constructor Bar ( Var Partner: Foo );
  end { Foo };

Constructor Foo.Bar ( Var Partner: Foo );

begin { Foo.Bar }
  writeln ( 'OK' );
end { Foo.Bar };

Var
  FooBar: Foo;

begin
  FooBar.Bar ( FooBar );
end.
