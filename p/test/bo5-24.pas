Program BO5_24;

Var
  t: LongInt = $FFFFFFFF;

begin
  inc ( t );
  if t = $100000000 then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', t );
end.
