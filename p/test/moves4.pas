Program Moves4;

Var
  Foo: Integer;

begin
  FillChar ( Foo );  { WRONG }
  writeln ( 'failed' );
end.
