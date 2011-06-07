{$R-}  { To range-check or not to range-check ... -- Frank, 20050106 }

Program Hamlet;

Var
  B: Byte = 242;
  Answer: Byte;

begin
  Answer:= ( 2 * B or not 2 ) * B;
  if Answer = 42 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
