Program BitSizes;

Var
  C: Char;

  R: packed record
    a: Boolean;
    b: 1..3;
  end { R };

begin
{
  writeln ( BitSizeOf ( C ) );
  writeln ( BitSizeOf ( R.a ) );
  writeln ( BitSizeOf ( R.b ) );
  writeln ( BitSizeOf ( R ) );
}
  if ( BitSizeOf ( C ) = 8 )
     and ( BitSizeOf ( R.a ) = 1 )
     and ( BitSizeOf ( R.b ) = 2 )
     and ( BitSizeOf ( R ) <= 8 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed ', BitSizeOf ( C ), ' ', BitSizeOf ( R.a ), ' ',
              BitSizeOf ( R.b ), ' ', BitSizeOf ( R ) );
end.
