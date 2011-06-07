Program Moves3;

Var
  foo: array [ 0..25 ] of Char = 'abcdefghijklmnopqrstuvwxyz';

begin
  MoveRight ( foo [ 3 ], foo [ 1 ], 22 );
  if foo = 'axyxyxyxyxyxyxyxyxyxyxyxyz' then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', foo );
end.
