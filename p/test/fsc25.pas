{$gnu-pascal}
program fsc25;
{function readStr}
uses GPC;
type Str =  String[20];
var s : Str;
   i  : 10..20;
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
   s:='24';
   {24 is out of the range of i (10..20)}
   ReadStr(s,i);
end.
