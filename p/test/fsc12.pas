program fsc12;
{enum write}
uses GPC;
type color         = (green, red, blue, yellow, brown, gray);
   restrectedcolor = green..blue;
var c : color;
   rc : restrectedcolor;
procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end; { ExpectError }
begin
   AtExit(ExpectError);
   c:=yellow;
   {rc is a subrange and yellow isn't in it.}
   rc:=c;
end.
