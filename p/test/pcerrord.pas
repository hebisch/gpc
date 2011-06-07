program PCErrorD;

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

{$extended-pascal}

begin
  AtExit (ExpectError);
  case 4 of 1:; end;
end.
