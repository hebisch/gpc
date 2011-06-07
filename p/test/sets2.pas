Program Sets2;

Var
  foo: Set of Char = [ 'O', 'K' ];

begin
  if 'M' in foo then
    writeln ( 'failed' )
  else
    writeln ( 'OK' );
end.
