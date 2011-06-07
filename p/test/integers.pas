Program Integers;

type
  Card17 = Cardinal attribute ( Size = 17 );

Var
  w: Word attribute ( Size = 4 );
  c: packed array [ 1..8 ] of Card17;
  x: LongestInt;
  y1: packed 12..133;
  y2: packed -12..255;

begin
  if ( SizeOf ( w ) = 1 )
   and ( SizeOf ( c ) >= 17 )
   and ( SizeOf ( x ) >= SizeOf ( LongInt ) )
   and ( SizeOf ( y1 ) = 1 )
   and ( SizeOf ( y2 ) = 2 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
