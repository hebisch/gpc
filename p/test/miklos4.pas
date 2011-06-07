Program Miklos4;

begin
  if Index ( "foo\tbar", "\t" ) = 4 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
