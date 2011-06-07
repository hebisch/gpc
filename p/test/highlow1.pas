Program HighLow1;

Type
  foo = 'K'..'O';
  bar = ( a, b, c );

begin
  if high ( Boolean ) and ( low ( bar) = a ) and ( high ( bar ) = c ) then
    writeln ( high ( foo ), low ( foo ) )
  else
    writeln ( 'failed' );
end.
