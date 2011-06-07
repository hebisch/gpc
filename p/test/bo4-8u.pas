Unit BO4_8u;

Interface

uses
  BO4_8v in 'bo4-8v.pas';

Type
  FoooPtr = ^FoooObj;

  FoooObj = object ( FooObj )
    K: Char;
  end { FoooObj };

Implementation

end.
