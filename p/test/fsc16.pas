program fsc16;
{range char write}
uses GPC;
var l : 'a'..'c';
   c : Char;
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
   c:='z';
   {assignment out of range (char)}
   l:=c;
end.
