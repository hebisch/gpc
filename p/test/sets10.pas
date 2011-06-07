Program Sets10;

Var
  c: Char;
  Counter: Integer = 0;

Function Count ( c: Char ): Char;

begin { Count }
  Count:= c;
  inc ( Counter );
end { Count };

begin
  for c:= 'Z' downto 'A' do
    if Count ( c ) in [ 'O', 'K' ] then
      write ( c );
  if Counter = 26 then
    writeln
  else
    writeln ( #8#8'failed' );
end.
