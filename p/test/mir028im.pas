program mir028im;
{Exclude with integer out of bounds, lower}
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
   k:=10;
   {k bellow the range}
   Exclude (SetA, k)
end.
