{$pointer-checking}

program PCErrorC;

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
ptr:^Char;

begin
  AtExit (ExpectError);
ptr:=nil;
Write (ptr^);
end.
