Program DNull2;

Type
  Range = 42..137;

Procedure Foo ( Var x: array [ a..b: Range ] of Char );

begin { Foo }
  if ( a in [ 42..137 ] ) and ( b in [ 42..137 ] ) and ( @x = Nil ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' )
end { Foo };

begin
  Foo ( Null )
end.
