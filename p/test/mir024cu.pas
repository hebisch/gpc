program mir024cu;
{function return with char out of bounds}
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
   k:='k';
   {k out of the range of char}
   Res := ReturnWithRange (k);
end.
