Program goto5;

Procedure Gnaa;

Label
  bar;

Procedure Foo;

begin { Foo }
  write ( 'O' );  { $debug-tree="Bar"}
  goto bar;  { $debug-tree="Bar"}
  write ( 'failed' );
end { Foo };

begin { Gnaa }
  Foo;
  write ( 'failed' );  { $debug-tree="Bar"}
  bar:  { $debug-tree="Bar"}
  writeln ( 'K' );
end { Gnaa };

begin
  Gnaa;
end.
