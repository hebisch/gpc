program fsc17;
{function returning range}
uses GPC;
type Result =  10 .. 100;
var i : Integer;
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
function outOfBounds(i : Integer) : Result;
begin
   outOfBounds:=i*2
end;
begin
   AtExit(ExpectError);
   {return an integer out of bounds}
   i:=outOfBounds(80);
   WriteLn(i);
end.
