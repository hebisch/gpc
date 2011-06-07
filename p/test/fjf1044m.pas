program fjf1044m;

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
  u (a, b, c: Integer) = array [a .. b] of Integer;
  tc = u (42, 84, Sqr (42));

function f (n: Integer): tc;
var d: u (n, 2 * n, Sqr (n - 84));
begin
  f := d
end;

begin
  AtExit (ExpectError);
  Discard (f (41))
end.
