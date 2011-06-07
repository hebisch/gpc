Program BO5_14;

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
  Bar:= 'OK';
end { Cmulb };

begin { FooObj.Bar }
  Cmulb;
end { FooObj.Bar };

begin
  writeln ( Foo.Bar );
end.
