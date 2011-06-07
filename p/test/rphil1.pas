UNIT TestUnit1;

INTERFACE

TYPE
    Wood  = (Oak, Pine, Beech, Teak);
    Fruit = (Apples, Peaches, Lemons);

CONST
    Oranges = Teak;

PROCEDURE CheckFruit ( FruitType : Fruit );

IMPLEMENTATION

PROCEDURE CheckFruit ( FruitType : Fruit );
BEGIN
CASE FruitType OF
  Apples  : WriteLn ('OK');
  Peaches : WriteLn ('Peaches');
  Lemons  : WriteLn ('Lemons');
  OTHERWISE WriteLn ('failed');
  END;
END;
END.
