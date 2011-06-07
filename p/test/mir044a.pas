program mir044a;
{procedure `not' with range}
uses GPC;
type range = 8..10;
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
   a := 8;
   not (a);
end.
