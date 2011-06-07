Program BO5_12;

{ FLAG -Werror }

Type
  FooPtr = ^FooObj;
  BarPtr = ^BarObj;

  FooObj = object
  end { FooObj };

  BarObj = object ( FooObj )
  end { BarObj };

Var
  Foo: FooPtr;
  Bar: BarPtr;

begin
  New ( Bar );
  Foo:= Bar;
  if ( Foo = Bar ) and ( Bar = Foo ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
