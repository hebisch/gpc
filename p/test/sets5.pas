Program Sets5;

Var
  O: set of Char = [ 'O', 'K' ];
  K: set of Char = [ 'K'..'O' ];

begin
  if O <= K then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
