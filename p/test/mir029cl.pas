program mir029cl;
{assigning sets to smaler subrange, char}
uses GPC;
type range1 = 'c'..'j';
     range2 = 'a'..'z';
var k : Char;
    SetA : set of range1 Value [];
    SetB : set of range2 Value ['a'];

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
