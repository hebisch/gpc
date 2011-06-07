Program Expon;

Const
  R: array [ 0 .. 1 ] of Real = ( 1.07177, 2.14355 );

Var
  i: Integer;

begin
  for i:= 0 to 1 do
    if abs ( 2 ** ( i + 0.1 ) - R [ i ] ) > 0.0001 then
      begin
        writeln ( 'failed: ', 2 ** ( i + 0.1 ) : 0 : 5 );
        Halt ( 1 )
      end { if };
  writeln ( 'OK' )
end.
