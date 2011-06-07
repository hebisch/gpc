Unit BO5_7u;


Interface


Type
  BasePtr = ^BaseObj;
  SubPtr = ^SubObj;

  BasePtrArray ( Capacity: Integer ) = array [ 0..Capacity - 1 ] of BasePtr;
  BasePtrArrayPtr = ^BasePtrArray;


BaseObj = object
  Constructor Init;
  Procedure Foo; virtual;
end { BaseObj };


SubObj = object ( BaseObj )
  Procedure Foo; virtual;
end { SubObj };


Implementation


Constructor BaseObj.Init;

begin { BaseObj.Init }
  { empty }
end { BaseObj.Init };


Procedure BaseObj.Foo;

Var
  Bar: BasePtrArrayPtr;

begin { BaseObj.Foo }
  write ( 'O' );
end { BaseObj.Foo };


Procedure SubObj.Foo;

Var
  Bar: BasePtrArrayPtr;

begin { SubObj.Foo }
  write ( 'K' );
end { SubObj.Foo };


end.
