Program PFEP1;

Procedure Bar;

Var
  Foo: set of Byte = [ 42 ];
  S: String ( 6 ) = 'not OK';
  T: String ( 6 ) = 'failed';

begin { Bar }
  if Foo <> [ ] then
    T:= Copy ( S, 5, 2 );
  writeln ( T );
end { Bar };

begin
  Bar;
end.
