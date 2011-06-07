Program BO4_4c;

{ FLAG -Werror }

Type
  Foo = object
    Procedure Bar ( Const Partner: Foo );
    Procedure Baz ( Const Partner: Foo );
  end { Foo };

Procedure Foo.Bar ( Const Partner: Foo );

begin { Foo.Bar }
  writeln ( 'OK' );
end { Foo.Bar };

Procedure Foo.Baz ( Const Partner: Foo );

begin { Foo.Baz }
  writeln ( 'failed' );
end { Foo.Baz };

Var
  FooBar: Foo;

begin
  FooBar.Bar ( FooBar );
end.
