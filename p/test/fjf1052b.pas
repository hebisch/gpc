{$pointer-checking}

program fjf1052b (Output);

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

type
  p = ^Integer;

const
  a = p (nil);

{$extended-pascal}

begin
  AtExit (ExpectError);
  WriteLn (a^)
end.
