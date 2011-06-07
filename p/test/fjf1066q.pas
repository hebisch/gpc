unit fjf1066q;

interface

implementation

type
  TObj = object
  end;

  SubObj = object (TObj)
    procedure Method;
  end;

procedure SubObj.Method;
begin
  WriteLn ('OK')
end;

var
  Obj: SubObj;
  PObj: ^TObj = @Obj;

type
  Foo = Integer;

Initialization
  (PObj^ as SubObj).Method;

end.
