program fjf911a;

uses GPC;

var
  a: Byte;
  b: set of 1 .. 10;

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
  a := 0;
  b := [a];
end.
