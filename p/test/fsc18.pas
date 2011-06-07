program fsc18;
{range as parameter}
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
procedure outOfBounds(r : Result);
begin
   WriteLn(r)
end;
begin
   AtExit(ExpectError);
   {return an integer out of bounds}
   i:=180;
   outOfBounds(i);
end.
