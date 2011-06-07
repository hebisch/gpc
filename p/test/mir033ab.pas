program mir033ab;
{procedure `shr' with range}
uses GPC;
type range = $100000000..$200000000;
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
   a := $100000000;
   shr (a, 2); { this should go over ubound }
end.
