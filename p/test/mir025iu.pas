program mir025iu;
{function return with integer out of bounds, upper}
uses GPC;
type range = 13..42;
var Res,k : Integer;

function ReturnWithRange (parm: Integer): range;
begin
  return parm;
end;

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
   {k above the range}
   Res := ReturnWithRange (k);
end.
