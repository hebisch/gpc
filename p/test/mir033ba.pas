program mir033ba;
{procedure `shl' with range}
uses GPC;
type range = 8..32;
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
   a := 16;
   shl (a, 2); { this should go bellow lbound }
end.
