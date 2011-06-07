Unit Maurice1u;

Interface

Implementation

Var
  i: Integer;
  S: array [ 1..2 ] of Char value 'OK';

to begin do
  for i:= 1 to 2 do
    write ( S [ i ] );

to end do
  writeln;

end.
