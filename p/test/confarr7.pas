Program ConfArr7;

Var
  OK: array [ 1..2, 3..4 ] of Char = ( 'xO', 'Ky' );

Procedure Foo ( Bar: array [ i..j: Integer ] of array [ k..l: Integer ] of Char );

begin { Foo }
{
  writeln ( i, j, k, l );
  writeln ( Bar [ i, k ], Bar [ j, l ] );
}
  writeln ( Bar [ i, l ], Bar [ j, k ] );
end { Foo };

begin
{
  writeln ( OK [ 1, 3 ], OK [ 2, 4 ] );
  writeln ( OK [ 1, 4 ], OK [ 2, 3 ] );
}
  Foo ( OK );
end.
