program fsc22;
{function pred}
uses GPC;
type color = (red, green, blue);
var c : color;
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
   c:=red;
   {the Pred (c) is out of range.}
   c:=Pred(c);
end.
