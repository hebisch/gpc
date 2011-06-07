Unit BO5_9u;

Interface

Type
  FooPtr = ^FooObj;
  FoooPtr = ^FoooObj;

  FooObj = object
    Constructor Init;
    Procedure OK ( p: FoooPtr ); virtual;
  end { FooObj };

  FoooObj = object ( FooObj )
  end { FoooObj };

Implementation

Constructor FooObj.Init;

begin { FooObj.Init }
  { empty }
end { FooObj.Init };

Procedure FooObj.OK ( p: FoooPtr );

begin { FooObj.OK }
  writeln ( 'failed' );
end { FooObj.OK };

end.
