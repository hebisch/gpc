Program ArcTanTest;

begin
  if abs ( arctan ( 1000 ) - 0.5 * 3.1415 ) < 0.0011 then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', arctan ( 1000 ) : 0 : 5 );
end.
