Program Sets5a;

Var
  O, K: set of Char;

begin
  O:= [ 'O', 'K' ];
  K:= [ 'K'..'O' ];
  if O <= K then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
