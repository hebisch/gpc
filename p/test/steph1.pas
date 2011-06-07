Program Stephane1;

Type
  BinSet = set of 1..17;

Var
  Foo: BinSet value [ 13 ];
  Bar: ByteInt value 7;

begin
  Foo:= Foo + [ Bar ];
  if Foo = [ 7, 13 ] then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
