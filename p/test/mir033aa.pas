program mir033aa;
{procedure `shr' with range}
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
   a := 8;
   shr (a, 3); { this should go over ubound }
end.
