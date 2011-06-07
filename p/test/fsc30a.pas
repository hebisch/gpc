program fsc30a;
{slice string read}
uses GPC;
var s, t  : String[20];
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
   t := s[i..j];
end.
