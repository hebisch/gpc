program fsc23;
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
   i:=43;
   {given the manual, must return a runtime error}
   WriteLn(SubStr(s,i));
end.
