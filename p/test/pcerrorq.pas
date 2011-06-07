program PCErrorQ;

import GPC;

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

var
r :Real;

begin
  AtExit (ExpectError);
r:=ln(0)
end.
