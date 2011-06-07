Unit BO5_9v;

Interface

uses
  BO5_9u in 'bo5-9u.pas';

Type
  BarPtr = ^BarObj;

  BarObj = object ( FoooObj )
    Procedure OK ( p: FoooPtr ); virtual;
  end { BarObj };

Implementation

Procedure BarObj.OK ( p: FoooPtr );

begin { BarObj.OK }
  writeln ( 'OK' );
end { BarObj.OK };

end.
