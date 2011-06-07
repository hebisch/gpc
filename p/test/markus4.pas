Program Markus4;

{ "logl" etc. did not work with DJGPP. }

Var
  x: LongReal;

begin
  x:= ln ( 2.7182818285 );
  if abs ( x - 1 ) < 0.00001 then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', x : 0 : 10 );
end.
