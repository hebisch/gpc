program mir027cl;
{Dec with char out of bounds, lower}
uses GPC;
type range = 'c'..'f';
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
   j:='a'; k:='f';
   {j out of the range}
   i := k;
   repeat
     Dec (i)
   until i = j;
end.
