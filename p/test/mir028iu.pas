program mir028iu;
{Include with integer out of bounds, upper}
uses GPC;
type range = 13..42;
var k : Integer;
    SetA : set of range;

procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end;

begin
   AtExit(ExpectError);
   k:=48;
   {k is above the range}
   Include (SetA, k)
end.
