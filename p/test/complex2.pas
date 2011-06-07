Program Complex2;

Var
  i: Complex;

begin
  i:= -1.0;
  i:= sqrt ( i );
  if sqr ( i ) = -1.0 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
