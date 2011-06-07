Program goto4;

Label
  bar;

Procedure Foo;

begin { Foo }
  write ( 'O' ); { $debug-tree="Bar"}
  goto bar; { $debug-tree="Bar"}
  write ( 'failed' );
end { Foo };

begin
  Foo;
  write ( 'failed' ); { $debug-tree="Bar"}
  bar: { $debug-tree="Bar"}
  writeln ( 'K' );
end.
