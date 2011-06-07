program mir034d;
{Val with 3rd var parm out of bounds}
uses GPC;
type range = 10..13;
var k : Integer;
    ec : range;

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
   Val ('123456789012345invalid', k, ec); { above ec's ubound }
end.
