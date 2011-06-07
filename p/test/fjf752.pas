program fjf752;

type
  MyObj = object
    procedure FoO;
  end;

procedure Check (const a, b: String);
begin
  if a <> b then
    begin
      WriteLn ('failed: `', a, ''', `', b, '''');
      Halt
    end
end;

procedure MyObj.FoO;
begin
  Check (CurrentRoutineName, 'MyObj.FoO')
end;

procedure BAr;
begin
  Check (CurrentRoutineName, 'BAr')
end;

const
  a = CurrentRoutineName;

var
  x: MyObj;

begin
  BAr;
  x.FoO;
  Check (CurrentRoutineName, 'main program');
  Check (a, 'top level');
  WriteLn ('OK')
end.
