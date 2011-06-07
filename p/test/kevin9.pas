program test(output);

begin
  if ( abs ( frac ( 3.14 ) - 0.14 ) < 1E-14 )
     and ( abs ( int ( 3.14 ) - 3.0 ) < 1E-14 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
