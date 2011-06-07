Program fjf74;

begin
  if ( int ( 4.2E100 ) = 4.2E100 )
     and ( frac ( 4.2E100 ) = 0 ) then
    writeln ( chr ( Round ( int ( 79.999 ) ) ),
              chr ( Round ( 100 * frac ( 42.750 ) ) ) )
  else
    writeln ( 'failed: ', int ( 4.2E100 ), ' ', frac ( 4.2E100 ) );
end.
