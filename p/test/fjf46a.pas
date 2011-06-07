Program fjf46a;

Const
  Foo: String ( 20 ) = 'bar';

begin
  readln ( Foo );  { WARN }
  writeln ( 'failed' );
end.
