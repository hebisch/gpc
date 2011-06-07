Program BO5_1;

Type
  IntArray ( Capacity: Integer ) = array [ 1..Capacity ] of Char;
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
      p^ [ 1 ]:= 'O';
      p^ [ 2 ]:= 'K';
    end { with };
  for i:= 1 to R.p^.Capacity do
    write ( R.p^ [ i ] );
  writeln;
end.
