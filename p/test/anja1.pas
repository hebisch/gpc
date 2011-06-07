Program Anja1;

Var
  x: Integer value -5;

begin
  x:= max ( 0, x );
  if x = 0 then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', x );
end.
