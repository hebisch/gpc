unit russ2b;

interface

uses russ2a;

type
  TwoObj = OBJECT
    MyOne : OneObj;
    procedure bbb(r : RRType);
  end;

implementation

procedure TwoObj.bbb(r : RRType);
begin
  MyOne.aaa(r);
end;

end.
