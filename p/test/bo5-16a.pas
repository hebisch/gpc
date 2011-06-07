Program BO5_16;

Const
  O = 'O';
  K = 'K';

Type
  FooPtr = ^FooObj;

  FooObj = object
    x, y: Char;
    Constructor Init ( SomeO, SomeK: Char );
    Destructor Fini; virtual;
    Procedure O;
    Procedure K;
  end { FooObj };

Var
  Foo: FooPtr;

Constructor FooObj.Init ( SomeO, SomeK: Char );

begin { FooObj.Init }
  x:= SomeO;
  y:= SomeK;
end { FooObj.Init };

Destructor FooObj.Fini;

begin { FooObj.Fini }
  { empty }
end { FooObj.Fini };

{ Following 2 procedures added which were really missing (now detected by GPC)
  Frank, 20030130 }
Procedure FooObj.O;
begin
end;

Procedure FooObj.K;
begin
end;

begin
  Foo:= New ( FooPtr, Init ( O, K ) );
  writeln ( Foo^.x, Foo^.y );
  Dispose ( Foo, Fini );
end.
