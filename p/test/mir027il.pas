program mir027il;
{Dec with integer out of bounds, lower}
uses GPC;
type range = 13..42;
var j,k,Res : Integer;
    i: range;

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
   j:=10; k:=42;
   {k out of the range}
   i := k;
   repeat
     Dec (i)
   until i = j;
end.
