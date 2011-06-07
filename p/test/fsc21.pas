{$gnu-pascal}
program fsc21;
{function setLength}
uses GPC;
type Str =  String[20];
var s : Str;
   i  : Integer;
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
   i:=25;
   {s is 20 char maximum, can't set its length to 25.}
   SetLength(s,i);
end.
