Program BO5_2;

Type
  IntArray ( Capacity: Integer ) = array [ 0..Capacity - 1 ] of Char;
  IntArrayPtr = ^IntArray;

Var
  i: Integer;

R: record
  p: ^IntArray;
end { R };

begin
  R.p:= New ( IntArrayPtr, 2 );
  with R do
    begin
      p^ [ 0 ]:= 'O';
      p^ [ 1 ]:= 'K';
    end { with };
  for i:= 0 to R.p^.Capacity - 1 do
    write ( R.p^ [ i ] );
  writeln;
end.
