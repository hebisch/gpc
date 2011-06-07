program mir027cu;
{Inc with char out of bounds, upper}
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
   j:='c'; k:='k';
   {k out of the range}
   i := j;
   repeat
     Inc (i)
   until i = k;
end.
