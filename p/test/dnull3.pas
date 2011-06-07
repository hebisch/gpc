Program DNull3;

Type
  Range = 42..137;

Procedure Foo ( Var x: array of Char );

begin { Foo }
  if @x = Nil then
    writeln ( 'OK' )
  else
    writeln ( 'failed' )
end { Foo };

begin
  Foo ( Null )
end.
