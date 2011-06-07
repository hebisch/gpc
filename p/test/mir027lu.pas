program mir027lu;
{Inc with longint out of bounds, upper}
uses GPC;
type range = 20000000013..20000000042;
var j,k,Res : LongInt;
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
   j:=20000000013; k:=20000000048;
   {k out of the range}
   i := j;
   repeat
     Inc (i)
   until i = k;
end.
