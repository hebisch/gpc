Program ConfArr6;

Var
  OK: array [ 1..2, 3..4 ] of Char = ( 'xO', 'Ky' );

Procedure Foo ( x: array [ i..j: Integer; k..l: Integer ] of Char;
                y: array [ m..n: Integer ] of array [ o..p: Integer ] of Char );

begin { Foo }
  if ( i = m )
     and ( j = n )
     and ( k = o )
     and ( l = p )
     and ( x [ i, k ] = y [ m, o ] )
     and ( x [ i, l ] = y [ m, p ] )
     and ( x [ j, k ] = y [ n, o ] )
     and ( x [ j, l ] = y [ n, p ] ) then
    writeln ( x [ i, l ], y [ n, o ] )
  else
    writeln ( 'failed' );
end { Foo };

begin
  Foo ( OK, OK );
end.
