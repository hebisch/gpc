Program fjf23;

type MyLong = Cardinal attribute (Size = 32);
Var
  a: Integer value -$80000000;
  S1, S2: String ( 20 );

begin
  WriteStr ( S1, ShortWord ( ( {$local R-} MyLong ( a ) {$endlocal} * 4 ) div $100000000 ) );
           { 65534, should be 2 }
  WriteStr ( S2, Word ( ( {$local R-} MyLong ( a ) {$endlocal} * 4 ) div $100000000 ) );
           { -2, should be 2 }
  if ( S1 = '2' ) and ( S2 = '2' ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', S1, ', ', S2 );
end.
