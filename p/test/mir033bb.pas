program mir033bb;
{procedure `shl' with range}
uses GPC;
type range = $100000001..$200000000;
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
   a := $200000000;
   shl (a, 2); { this should go bellow lbound }
end.
