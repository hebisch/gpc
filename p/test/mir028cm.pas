program mir028cm;
{Exclude with char out of bounds, lower}
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
   k:='a';
   {k bellow the range}
   Exclude (SetA, k)
end.
