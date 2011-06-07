Program ConfArr5;


Var
  o: array [ 1..4 ] of Boolean = ( false, true, true, false );
  k: packed array [ 1..4 ] of Boolean;


Procedure Foo ( x: array [ i..j: Integer ] of Boolean;
                Var y: packed array [ k..l: Integer ] of Boolean );

begin { Foo }
  Pack ( x, k, y );
{
  writeln ( 'x: ', PtrCard ( @x ), ' ', x [ 1 ], ' ', x [ 2 ], ' ', x [ 3 ], ' ', x [ 4 ] );
  writeln ( 'y: ', PtrCard ( @y ), ' ', y [ 1 ], ' ', y [ 2 ], ' ', y [ 3 ], ' ', y [ 4 ] );
}
end { Foo };


Procedure Bar ( x: packed array [ i..j: Integer ] of Boolean;
                Var y: array [ k..l: Integer ] of Boolean );

begin { Bar }
  Unpack ( x, y, k );
end { Bar };


begin
  Foo ( o, k );
  if not k [ 1 ] and k [ 2 ] and k [ 3 ] and not k [ 4 ] then
    begin
      Bar ( k, o );
      if not o [ 1 ] and o [ 2 ] and o [ 3 ] and not o [ 4 ] then
        writeln ( 'OK' )
      else
        writeln ( 'failed (Bar) ', o [ 1 ], ' ', o [ 2 ], ' ', o [ 3 ], ' ', o [ 4 ] );
    end { if }
  else
    writeln ( 'failed (K: ', PtrCard ( @k ), ' ', k [ 1 ], ' ', k [ 2 ], ' ', k [ 3 ], ' ', k [ 4 ], ')' );
end.
