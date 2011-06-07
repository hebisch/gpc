program fjf1044y;

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

procedure q (c: tc);
begin
end;

procedure p (n: Integer);
var d: u (n, 2 * n, Sqr (n - 84));
begin
  q (d);
end;

begin
  AtExit (ExpectError);
  p (41)
end.
