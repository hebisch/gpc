Unit markus7u;


Interface

  type
    intDblArray ( l, ls: integer ) =
      array [ 0..l - 1, 0..ls - 1 ] of integer;
    intDblPtr = ^intDblArray;

  var
    vCar: intDblPtr value nil;


Implementation


end.
