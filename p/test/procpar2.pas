Program ProcParm2;

Procedure Bar ( x: Integer );

begin { Bar }
  writeln ( 'OK' );
end { Bar };

Procedure Foo2 ( Procedure Bar ( x: Integer ) );

begin { Foo2 }
  Bar ( 42 );
end { Foo2 };

Procedure Foo1 ( Procedure Bar ( x: Integer ) );

begin { Foo1 }
  Foo2 ( Bar );
end { Foo1 };

begin
  Foo1 ( Bar );
end.
