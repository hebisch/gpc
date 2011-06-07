Program HighLow2;

Var
  foo: 'K'..'O';
  bar: Boolean;
  baz: ( a, b, c );

begin
  if low ( bar ) or ( high ( baz ) <> c ) or ( low ( baz ) <> a ) then
    writeln ( 'failed' )
  else
    writeln ( high ( foo ), low ( foo ) );
end.
