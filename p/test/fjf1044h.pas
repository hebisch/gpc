program fjf1044h;

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
  t (n: Integer) = array [1 .. n] of Integer;

procedure p (n: Integer);
var
  a: t (42);
  b: t (n);
begin
  a := b
end;

begin
  AtExit (ExpectError);
  p (41)
end.
