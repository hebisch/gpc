program mir022il;
{procedure call with integer out of bounds, lower}
uses GPC;
type range = 2..36;
var k : Integer;

procedure CallWithRange (myInt: range);
begin
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
   k:=0;
   {k bellow the range}
   CallWithRange (k);
end.
