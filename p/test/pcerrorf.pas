program PCErrorF;

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
s :set of 1..4;
i :Integer;

begin
  AtExit (ExpectError);
        i:=5;
        s:=[1..i];
end.
