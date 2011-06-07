Program BO5_18;

{$x+}

Procedure Foo ( Procedure Bar ( Baz: Pointer ) );

begin { Foo }
  Bar ( Nil );
end { Foo };

Procedure Bar ( Baz: Pointer );

begin { Bar }
  writeln ( 'OK' );
end { Bar };

Type
  Proc = Procedure ( Baz: Pointer );

Var
  CallFoo: Procedure ( Bar: Proc ) = Foo;

begin
  CallFoo ( Bar );
end.
