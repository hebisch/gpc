program fjf1044n;

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

function g (n: Integer) = r: tc;
var d: u (n, 2 * n, Sqr (n - 84));
begin
  r := d
end;

begin
  AtExit (ExpectError);
  Discard (g (41))
end.
