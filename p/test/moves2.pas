Program Moves2;

Var
  foo: array [ 0..25 ] of Char = 'abcdefghijklmnopqrstuvwxyz';

begin
  MoveLeft ( foo [ 1 ], foo [ 3 ], 22 );
  if foo = 'abcbcbcbcbcbcbcbcbcbcbcbcz' then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', foo );
end.
