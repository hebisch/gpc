Program BPbug;

Var
  x: LongInt;

begin
  x:= $100000;
  x:= x shr 20;
  if x = 1 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
