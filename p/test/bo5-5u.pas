Unit BO5_5u;

Interface

Type
  CharArray ( Capacity: Integer ) = array [ 1..Capacity ] of Char;

Procedure WriteIt ( Var what: CharArray );

Implementation

Procedure WriteIt ( Var what: CharArray );

Var
  i: Integer;

begin { WriteIt }
  for i:= 1 to what.Capacity do
    write ( what [ i ] );
  writeln;
end { WriteIt };

end.
