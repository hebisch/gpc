{ Introduced the type declaration. Previously, both arrays were `of 0..3'.
  But EP 6.7.5.4 demands the component types to be the same, not only
  compatible. GPC detects this now. Frank, 20030417 }

Program Pack6;

Type
  T03 = 0..3;

Var
  p: packed array [ 1..4 ] of T03;
  u: array [ 1..4 ] of T03;
  i: Integer;

begin
  for i:= 1 to 4 do
    u [ i ]:= i - 1;
  pack ( u, 1, p );
  for i:= 1 to 4 do
    if p [ i ] <> i - 1 then
      write ( 'failed: p', i, '=', p [ i ], '; ' );
  writeln ( 'OK' );
end.
