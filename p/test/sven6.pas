Program Sven6;

Const
  A = $01000000;

begin
  if A = Integer ( 1 ) shl 24 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
