program mir044b;
{procedure `not' with range}
uses GPC;
type range = $ffffff00..$ffffffff;
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
   a := $fffffff8;
   not (a); { goes under }
end.
