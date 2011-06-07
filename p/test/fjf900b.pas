program fjf900b;

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
  t (n: Integer) = array [2 .. n] of Integer;

var
  v: ^t;
  i: Integer = 1;

begin
  AtExit (ExpectError);
  New (v, i)
end.
