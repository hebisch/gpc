program fjf917b;

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

{$extended-pascal}

var
  p: ^Integer Value nil;

begin
  AtExit (ExpectError);
  Dispose (p)
end.
