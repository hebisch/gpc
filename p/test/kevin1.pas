Program Kevin1;

Function Foo: Integer;

begin { Foo }
  Foo:= 42;
end { Foo };

Procedure Bar ( Answer: Cardinal );

begin { Bar }
  if Answer = 42 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end { Bar };

begin
  Bar ( Foo );
end.
