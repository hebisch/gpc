Program Bool;

Var
  Ch: Char value 'C';

begin
  if ( Ch >= 'A' ) and ( Ch <= 'Z' ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
