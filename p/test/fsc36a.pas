program fsc36a;
{? for with range }
uses GPC;
type range = 10..20;
var j,k,Res : Integer;
    i: range;

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
   j:=5; k:=15;
   {j out of the range of i}
   for i:=j to k do
      Res:=k;
end.
