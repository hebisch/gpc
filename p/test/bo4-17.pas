Program BO4_17;

Type
  Foo = object
    X: Integer;
    Procedure Baz ( Y: Integer );
  end { Foo };

  Bar = object ( Foo )
    Y: Integer;
  end { Bar };

Var
  FooBar: Bar;

Procedure Foo.Baz ( Y: Integer );

begin { Foo.Baz }
  X:= Y;
  writeln ( 'OK' );
end { Foo.Baz };

begin
  FooBar.Baz ( 42 );
end.
