program fjf1044o;

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

function h (n: Integer): tc;
var d: u (n, 2 * n, Sqr (n - 84));
begin
  Return d
end;

begin
  AtExit (ExpectError);
  Discard (h (41))
end.
