program mir028cu;
{Include with char out of bounds, upper}
uses GPC;
type range = 'c'..'f';
var k : Char;
    SetA : set of range;

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
   {k is above the range}
   Include (SetA, k)
end.
