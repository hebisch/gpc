Program fjf7;

Var
  S: String ( 80 );

begin
  WriteStr ( S, '' : 5, 'OKabcdefg' : 7 );
  if length ( S ) = 5 + 7 then
    writeln ( S [ 6..7 ] )
  else
    writeln ( 'failed' );
end.
