program LongRealBug;
{ Dagegen ist Intels legendärer Pentium-Bug eine Kleinigkeit!!!}

const
  Pi = 3.14159265358979323846;

var
  Pi_L : LongReal;
  Pi_R : Real;
  S : String ( 10 );

begin
  Pi_L := Pi;
  Pi_R := Pi;

  WriteStr( S, sin(Pi)   :10:5 );
  if ( S <> '   0.00000' ) and ( S <> '  -0.00000' ) then
    writeln ( 'failed' );
  WriteStr( S, sin(Pi_L) :10:5 );
  if ( S <> '   0.00000' ) and ( S <> '  -0.00000' ) then
    writeln ( 'failed' );
  WriteStr( S, sin(Pi_R) :10:5 );
  if ( S <> '   0.00000' ) and ( S <> '  -0.00000' ) then
    writeln ( 'failed' );

  WriteStr( S, cos(Pi)   :10:5 );
  if S <> '  -1.00000' then
    writeln ( 'failed' );
  WriteStr( S, cos(Pi_L) :10:5 );
  if S <> '  -1.00000' then
    writeln ( 'failed' );
  WriteStr( S, cos(Pi_R) :10:5 );
  if S <> '  -1.00000' then
    writeln ( 'failed' );

  writeln ( 'OK' );
end.
