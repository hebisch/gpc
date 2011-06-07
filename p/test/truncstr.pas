Program TruncStr;

{ FLAG --no-truncate-strings }

Var
  Foo: String ( 3 ) = 'FooBar';  { WRONG }

begin
  writeln ( 'failed' );
end.
