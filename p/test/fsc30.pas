program fsc30;
{slice string write}
uses GPC;
var s  : String[20];
   i,j : Integer;
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
   s:='hello world';
   i:=16; j:=25;
   s[i..j]:='how are U?';
end.
