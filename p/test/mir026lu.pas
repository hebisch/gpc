program mir026lu;
{function return with long integer out of bounds, upper}
uses GPC;
type range = 20000000013..20000000042;
var Res,k : LongInt;

function ReturnWithRange (parm: LongInt): range;
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
   k:=20000000048;
   {k above the range}
   Res := ReturnWithRange (k);
end.
