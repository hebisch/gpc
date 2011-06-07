Unit markus6u;


Interface

  type
    pruzzelArray ( i: integer ) = array [ 1..i ] of integer;
    pruzzelPtr = ^pruzzelArray;

  var
    pruzzel: pruzzelPtr;


Implementation


end.
