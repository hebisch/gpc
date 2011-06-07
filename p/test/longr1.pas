Program LongReal1;

Var
  x: LongReal;

begin
  x:= 4.2E250;
  if Round ( x / 0.1E250 ) = 42 then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', x / 0.1E250 );
end.
