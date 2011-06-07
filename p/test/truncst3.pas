Program TruncSt3;

{$truncate-strings}

Var
  Foo: String ( 3 );

begin
  WriteStr (Foo, 'abcdef');
  if Foo = 'abc' then WriteLn ('OK') else WriteLn ('failed')
end.
