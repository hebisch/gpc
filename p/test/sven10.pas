Program Sven10;

begin
  if ( abs ( 2.0 pow 2 - 4 ) < 1E-10 )
     and ( abs ( 2 ** 2 - 4 ) < 1E-10 )
     and ( 2 pow 2 = 4 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', 2.0 pow 2 : 0 : 2,
              ', ', 2 ** 2 : 0 : 2,
              ', ', 2 pow 2 );
end.
