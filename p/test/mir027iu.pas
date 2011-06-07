program mir027iu;
{Inc with integer out of bounds, upper}
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
   j:=13; k:=48;
   {k out of the range}
   i := j;
   repeat
     Inc (i)
   until i = k;
end.
