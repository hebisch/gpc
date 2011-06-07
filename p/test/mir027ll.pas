program mir027ll;
{Dec with longint out of bounds, lower}
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
   j:=20000000010; k:=20000000042;
   {j out of the range}
   i := k;
   repeat
     Dec (i)
   until i = j;
end.
