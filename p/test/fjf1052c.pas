{$pointer-checking}

program fjf1052c (Output);

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
  a: ^Integer = nil;

begin
  AtExit (ExpectError);
  WriteLn (a^)
end.
