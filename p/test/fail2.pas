Program Fail2;

{ FLAG -Werror }

Type
  FooPtr = ^FooObj;
  FooObj = object
    Constructor Init;
  end { FooObj };

Var
  Foo: FooPtr;

Constructor FooObj.Init;

begin { FooObj.Init }
  { Nix Fail; }
end { FooObj.Init };

begin
  Foo:= Nil;
  Foo:= New ( FooPtr, Init );
  if Foo = Nil then
    writeln ( 'failed' )
  else
    writeln ( 'OK' );
end.
