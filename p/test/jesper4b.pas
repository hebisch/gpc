Program Jesper4b;

Type
  ProcRef = Procedure;

Procedure Foo;

begin { Foo }
  writeln ( 'failed' );
end { Foo };

Procedure Bar ( P: ProcRef );

begin { Bar }
  P;
end { Bar };

begin
  Bar ( @Foo );  { WRONG (extra `@') }
end.
