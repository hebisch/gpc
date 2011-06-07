program fsc37;
{? for with char out of bounds}
uses GPC;
type range = 'c'..'j';
var j,k,Res : Char;
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
   j:='e'; k:='n';
   {k out of the range of i (char)}
   for i:=j to k do
      Res:=k;
end.
