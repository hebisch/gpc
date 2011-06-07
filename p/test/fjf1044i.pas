program fjf1044i;

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

procedure p (n: Integer);
var
  c: u (n, 2 * n, Sqr (n));
  d: u (n, 2 * n, Sqr (n - 84));
begin
  c := d
end;

begin
  AtExit (ExpectError);
  p (41)
end.
