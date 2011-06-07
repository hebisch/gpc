Program Complex3;

Const
  epsilon = 1E-15;

Var
  one: Real = 1;
  i: Complex;

begin
  i:= - one;
  i:= sqrt ( i );
  if abs ( 2 * sqr ( i ) + 2.0 ) < epsilon then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
