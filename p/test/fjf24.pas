program fjf24;
type card64 = cardinal attribute (Size = 64);
var y:packed record z:card64; end;
begin
  if ( SizeOf ( y ) = 8 ) and ( BitSizeOf ( y.z ) = 64 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
