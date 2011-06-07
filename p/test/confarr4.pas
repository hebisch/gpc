Program ConfArr4;

Const
  OK: packed array [ 1..2 ] of Char = 'OK';

Procedure Foo ( Bar: packed array [ i..j: Integer ] of Char );

begin { Foo }
  writeln ( Bar );
end { Foo };

begin
  Foo ( OK );
end.
