Program TruncSt4;

Var
  Foo: String ( 3 );

begin
  WriteStr (Foo, 'abcdef');
  if Foo = 'abc' then WriteLn ('OK') else WriteLn ('failed')
end.
