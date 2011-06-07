program fsc24;
{function succ enum}
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
   c:=blue;
   {the Succ(c) is out of range.}
   c:=Succ(c);
end.
