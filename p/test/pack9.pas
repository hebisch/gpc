Program Pack9;

Type
  MetaSyntactical = ( foo, bar, baz );

Var
  flag: packed array [ MetaSyntactical ] of Boolean;
  m: MetaSyntactical;

begin
  for m:= foo to baz do
    flag [ m ]:= odd ( ord ( m ) );
  if not flag [ foo ] and flag [ bar ] and not flag [ baz ] then
    writeln ( 'OK' )
  else
    writeln ( 'failed ', flag [ foo ], ' ', flag [ bar ], ' ', flag [ baz ] );
end.
