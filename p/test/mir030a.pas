program mir030a;
{procedure `and' with range}
uses GPC;
type range = 6..12;
var  a : range;

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
   a := 6;
   and (a, 10);
   { `and' can't overflow ... we test only going under lower bound }
end.
