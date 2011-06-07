Program Sam7;

Var
  foo: array [ 'a'..'f' ] of Boolean = ( false, false, true, false, false, false );
  bar: packed array [ 42..47 ] of Boolean;
  baz: array [ '0'..'5' ] of Boolean;
  i: Integer;

begin
  pack ( foo, 'a', bar );
  unpack ( bar, baz, '0' );
  for i:= 0 to 5 do
    if bar [ 42 + i ] <> baz [ succ ( '0', i ) ] then
      foo [ 'c' ]:= false;
  if foo [ 'c' ] and bar [ 44 ] then
    writeln ( 'OK' )
  else
    writeln ( 'failed ', foo [ 'c' ], ' ', bar [ 44 ] );
end.
