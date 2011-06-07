program mir023ll;
{procedure call with long integer out of bounds, lower}
uses GPC;
type range = 20000000000..20000000036; { :-) }
var k : LongInt;

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
   k:=19999999998;
   {k bellow the longint range}
   CallWithRange (k);
end.
