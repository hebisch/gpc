program mir029iu;
{assigning sets to smaler subrange, integer}
uses GPC;
type range1 = 10..13;
     range2 = 1..42;
var k : Char;
    SetA : set of range1 Value [];
    SetB : set of range2 Value [42];

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
   SetA := SetB;
end.
