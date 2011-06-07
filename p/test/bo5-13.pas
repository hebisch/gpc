Program BO5_13;

Type
  S2 = String ( 2 );

  FooObj = object
    Function Bar: S2;
  end { FooObj };

Var
  Foo: FooObj;

Function FooObj.Bar: S2;

Procedure Cmulb;

begin { Cmulb }
end { Cmulb };

begin { FooObj.Bar }
  Bar:= 'OK';
end { FooObj.Bar };

begin
  writeln ( Foo.Bar );
end.
