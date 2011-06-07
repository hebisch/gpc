program fjf965a;

uses GPC;

var
  i: Integer;

procedure ExpectError;
begin
  InOutRes := 0;
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
  ReadStr ('', i)
end.
