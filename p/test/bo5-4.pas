Program BO5_2;

Type
  IntArray ( Capacity: Integer ) = array [ 0..Capacity - 1 ] of Char;
  IntArrayPtr = ^IntArray;

Var
  i: Integer;
  p: IntArrayPtr;

begin
  p:= New ( IntArrayPtr, 7 );
  p:= New ( IntArrayPtr, 2 );
  p^ [ 0 ]:= 'O';
  p^ [ 1 ]:= 'K';
  for i:= 0 to p^.Capacity - 1 do
    write ( p^ [ i ] );
  writeln;
end.
