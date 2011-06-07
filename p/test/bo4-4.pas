Program BO4_4;

Type
  Foo = object
    Constructor Bar ( Partner: Foo );  { WARN: object as value parameter }
  end { Foo };

Constructor Foo.Bar ( Partner: Foo );

begin { Foo.Bar }
  writeln ( 'failed' );
end { Foo.Bar };

Var
  FooBar: Foo;

begin
  FooBar.Bar ( FooBar );
end.
