Program BO5_15;

Type
  FooObj = object
    Constructor Beginning;
    Function Answer: Integer; virtual;
  end { FooObj };

  BarObj = object ( FooObj )
    Function Answer: Integer; virtual;
  end { BarObj };

Var
  The: BarObj;

Constructor FooObj.Beginning;

begin { FooObj.Beginning }
end { FooObj.Beginning };

Function FooObj.Answer: Integer;

begin { FooObj.Answer }
  Answer:= 21;
end { FooObj.Answer };

Function BarObj.Answer: Integer;

Procedure DeepThought;

begin { DeepThought }
end { DeepThought };

begin { BarObj.Answer }
  Answer:= inherited Answer + 21;
end { BarObj.Answer };

begin
  The.Beginning;
  if The.Answer = 42 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
