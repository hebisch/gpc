{$case-value-checking}

program fjf1012d (Output);

import GPC;

var
  i: Integer Value 10;

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
  case i of
    1: WriteLn ('failed 1');
  end;
  WriteLn ('failed 2')
end.
