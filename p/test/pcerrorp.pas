program PCErrorP;

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
r:=sqrt(-1.0)
end.
