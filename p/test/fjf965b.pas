program fjf965b;

uses GPC;

var
  i: Integer;
  f: Text;

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
  Write (f, i)
end.
