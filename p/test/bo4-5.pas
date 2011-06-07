Program BO4_5;

Type
  Proc = Procedure ( Answer: Integer );

Var
  Foo: Pointer;


Procedure Bar ( Answer: Integer );

begin { Bar }
  if Answer = 42 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end { Bar };


begin
  Foo:= @Bar;
  Proc ( Foo ) ( 42 );
end.
