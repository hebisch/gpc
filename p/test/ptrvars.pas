Program PtrVars;

Var
  OK: ^String = @'OK';
  p: ^String = @'failed';

Procedure Foo ( Var q: Pointer );

begin { Foo }
  q:= OK;
end { Foo };

begin
  Foo ( p );
  writeln ( p^ );
end.
