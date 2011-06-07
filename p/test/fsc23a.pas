program fsc23a;
{function substr}
uses GPC;
var s :  String(42);
    i :  Integer;
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
   s:='Hello';
   i:=5;
   {given the manual, must return a runtime error}
   WriteLn(SubStr(s,i,2));
end.
