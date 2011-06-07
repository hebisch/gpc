program testrl(output);
uses GPC;
const bitsize = 4;
type c4 = Cardinal attribute(Size = bitsize);
var j: c4; i: Integer;

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
  AtExit (ExpectError);
  i := 0;
  j := 0;
  repeat
    i := i + 1;
    j := j + 1;
  until (j = 32) or (i = 100);
end.
