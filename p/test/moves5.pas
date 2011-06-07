Program Moves5;

Var
  Foo: Integer;

begin
  MoveLeft ( Foo );  { WRONG }
  writeln ( 'failed' );
end.
