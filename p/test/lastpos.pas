Program LastPos;

Type
  Foo = array [ 1..3 ] of Char;

Var
  F, O: Foo = 'foo';
  Bar: file [ 40..100 ] of Foo;

begin
  rewrite ( Bar );
  write ( Bar, F, O, O );
  if LastPosition ( Bar ) = 42 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
  close ( Bar );
end.
