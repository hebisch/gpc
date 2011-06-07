Program Sets5b;

Var
  O: set of Char = [ 'O', 'K' ];
  K: set of 'K'..'O' = [ 'K'..'O' ];

begin
  if O <= K then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
