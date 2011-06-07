program fsc15;
{range integer write}
uses GPC;
var i : 1..10;
   j  : Integer;
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
   j:=15;
   {assignment out of range}
   i:=j;
end.
