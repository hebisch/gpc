Program Schema1;

Type
  SubRange ( u: Integer ) = 1..u;
  RealArray ( u, v: Integer) = array [ 1..u, 1..v ] of Real;

Var
  i: SubRange ( 10 );
  j: SubRange ( 12 );
  Summe1, Summe2: Integer value 0;
  MyArray: ^RealArray;
  Check: ^String;

begin
  New ( MyArray, 1, 2 );
  New ( MyArray, 10, 12 );
  New ( Check, 100 );
  Check^:= 'Dies ist ein Test.';
  for i:= 1 to MyArray^.u do
    for j:= 1 to MyArray^.v do
      MyArray^ [ i, j ]:= 12 * i + j;
  for i:= 1 to MyArray^.u do
    for j:= 1 to MyArray^.v do
      begin
        Summe1:= Summe1 + Round ( MyArray^ [ i, j ] );
        Summe2:= Summe2 + 12 * i + j;
      end { for };
  if ( SizeOf ( MyArray^ ) = 10 * 12 * SizeOf ( Real ) + 2 * SizeOf ( Integer ) )
   and ( Summe1 = Summe2 )
   and ( Check^ = 'Dies ist ein Test.' ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', SizeOf ( MyArray^ ), ' ', Summe1, ' ', Summe2, ' ', Check^ );
  Dispose ( MyArray );
end.
