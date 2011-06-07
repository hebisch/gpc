program fjf911d;

uses GPC;

type
  t = set of 1 .. 10;

var
  a: Byte;

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

procedure Foo (b: t);
begin
end;

begin
  AtExit (ExpectError);
  a := 11;
  Foo ([a])
end.
