Program BO5_8;


Type
  FirstPtr = ^FirstObj;
  SecondPtr = ^SecondObj;


  FirstObj = object
    Constructor Init1;
    Constructor Init2;
    Procedure OK; virtual;
  end { FirstObj };


  SecondObj = object ( FirstObj )
    Procedure OK; virtual;
  end { SecondObj };


Var
  SomeObj: FirstPtr;


Constructor FirstObj.Init1;

begin { FirstObj.Init1 }
  { Without the prefix `FirstObj', the object is re-initialized }
  { - in GPC as well as in BP.  Let's consider it a feature ... }
  FirstObj.Init2;
end { FirstObj.Init1 };


Constructor FirstObj.Init2;

begin { FirstObj.Init2 }
  { empty }
end { FirstObj.Init2 };


Procedure FirstObj.OK;

begin { FirstObj.OK }
  writeln ( 'failed' );
end { FirstObj.OK };


Procedure SecondObj.OK;

begin { SecondObj.OK }
  writeln ( 'OK' );
end { SecondObj.OK };


begin
  SomeObj:= New ( SecondPtr, Init1 );
  SomeObj^.OK;
end.
