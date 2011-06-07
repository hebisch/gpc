program fjf40c;

uses GPC;

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
  s : String (10) = 'OK';

begin
  AtExit (ExpectError);
  s := SubStr (s, 1, 4);
  Write ('failed ')
end.
