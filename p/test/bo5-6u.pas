Unit BO5_6u;

Interface

Type
  CharArray ( Capacity: Integer ) = array [ 1..Capacity, 1..Capacity ] of Char;

Procedure WriteIt ( Var what: CharArray );

Implementation

Procedure WriteIt ( Var what: CharArray );

begin { WriteIt }
  write ( what [ 1, 1 ] );
  writeln ( what [ 2, 2 ] );
end { WriteIt };

end.
