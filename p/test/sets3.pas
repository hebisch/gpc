Program Sets3;

{$W-}

Var
  x: Integer = 1;

begin
  if [ 0 ] < [ x ] then
    writeln ( 'failed: ', SizeOf ( x ) )
  else
    writeln ( 'OK' );
end.
