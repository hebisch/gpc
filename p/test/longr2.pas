{ COMPILE-CMD: longr2.cmp }

Program LongReal2;

Var
  x: LongReal;

begin
  x:= 4.2E250;    { Not all machines support this. }
  x:= sqr ( x );
  x:= sqrt ( x );
  if Round ( x / 0.1E250 ) = 42 then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', x / 0.1E250 );
end.
