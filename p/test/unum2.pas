Unit Unum2;

Interface

Procedure Foo2;

Implementation

Procedure Foo2;

Procedure Bar;

begin { Bar }
  writeln ( 'K' );
end { Bar };

begin { Foo2 }
  Bar;
end { Foo2 };

end.
