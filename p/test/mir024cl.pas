program mir024cl;
{function return with integer out of bounds}
uses GPC;
type range = 'c'..'f';
var Res,k : Char;

function ReturnWithRange (parm: Char): range;
begin
  return parm;
end;

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
   k:='a';
   {k out of the range}
   Res := ReturnWithRange (k);
end.
