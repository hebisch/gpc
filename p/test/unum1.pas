Unit Unum1;

Interface

Procedure Foo1;

Implementation

Procedure Foo1;

Procedure Bar;

begin { Bar }
  write ( 'O' );
end { Bar };

begin { Foo1 }
  Bar;
end { Foo1 };

end.
