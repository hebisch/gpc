Program PtrArith;

{$X+}

Var
  S: array [ 1..6 ] of Integer;
  p: ^Integer;

begin
  if p < p then
    writeln ( 'failed' );
  p:= @S [ 6 ];
  if p - @S [ 1 ] <> 5 then
    writeln ( 'failed' );
  for p:= @S [ 1 ] to @S [ 6 ] do
    p^:= ord ( 'O' );
  for p:= @S [ 6 ] downto @S [ 4 ] do
    p^:= ord ( 'K' );
  p:= @S [ 3 ];
  while p < @S [ 5 ] do
    begin
      write ( chr ( p^ ) );
      inc ( p );
    end { while };
  writeln;
end.
