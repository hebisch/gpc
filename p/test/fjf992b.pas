{ Out of range in `Val' error position -> ordinary range error }

program fjf992b;

uses GPC;

var
  a: Integer;
  b: 1 .. 3;

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
  Val ('1234x', a, b)
end.
