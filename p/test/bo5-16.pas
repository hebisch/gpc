Program BO5_16;

Const
  O = 'O';
  K = 'K';

Type
  FooPtr = ^FooObj;

  FooObj = object
    O, K: Char;
    Constructor Init ( SomeO, SomeK: Char );
  end { FooObj };

Var
  Foo: FooPtr;

Constructor FooObj.Init ( SomeO, SomeK: Char );

begin { FooObj.Init }
  O:= SomeO;
  K:= SomeK;
end { FooObj.Init };

begin
  Foo:= New ( FooPtr, Init ( O, K ) );
  writeln ( Foo^.O, Foo^.K );
end.
