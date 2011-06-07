program fjf1047b (Output);

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
  t = 'a' .. Chr (200);

var
  a: -200 .. 100;
  b: t;

begin
  AtExit (ExpectError);
  a := -134;
  b := t (a);
end.
