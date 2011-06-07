Program Test;


Type

TestObj = object
  FooBar: array [ 0..27 ] of Char;
end { TestObj };


Procedure Init ( x: Integer );

begin { TestObj.Init  }
  x:= 7;
end { TestObj.Init };


begin
  Init ( 3 );
  writeln ( 'OK' );
end.
