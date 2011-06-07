Program goto3;

Procedure Foo;

Label
  bar;

begin { Foo }
  write ( 'O' );
  goto bar;
  write ( 'failed' );
  bar:
  writeln ( 'K' );
end { Foo };

begin
  Foo;
end.
