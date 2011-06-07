Program Schema2a;

Var
  p: ^String;

begin
  New ( p, 42 );
  if SizeOf ( p^ ) = ( 42 + 3 * SizeOf (Cardinal) - 1 )
     div AlignOf ( p^ ) * AlignOf ( p^ ) then
    p^:= 'OK'
  else
    p^:= 'failed';
  writeln ( p^ );
end.
