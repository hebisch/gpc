Program Fail1;

Type
  FooPtr = ^FooObj;
  FooObj = object
    Constructor Init;
  end { FooObj };

Var
  Foo: FooPtr;

Constructor FooObj.Init;

begin { FooObj.Init }
  Fail;
end { FooObj.Init };

begin
  Foo:= New ( FooPtr, Init );
  if Foo = Nil then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
