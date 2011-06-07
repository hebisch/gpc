Program FillCh;

Var
  ooookkkk: array [ 1..8 ] of Char;

begin
  FillChar ( ooookkkk, 4, 'O' );
  FillChar ( ooookkkk [ 5 ], 4, ord ( 'K' ) );
  writeln ( ooookkkk [ 4..5 ] );
end.
