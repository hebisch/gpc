Program Jesper4a;

Type
  ProcPtr = ^Procedure;

Procedure Foo;

begin { Foo }
  writeln ( 'failed' );
end { Foo };

Procedure Bar ( P: ProcPtr );

begin { Bar }
  P^;
end { Bar };

begin
  Bar ( Foo );  { WRONG (missing `@') }
end.
