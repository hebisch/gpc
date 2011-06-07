program mir034e;
{ReadStr with source out of bounds}
uses GPC;
type range = 10..13;
var k : range;

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
   ReadStr ('14', k); { over ubound }
end.
