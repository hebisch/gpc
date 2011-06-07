program fjf1044c;

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
  c: array [1 .. 10] of u (n, 2 * n, Sqr (n));
  d: packed array [21 .. 30] of u (n, 2 * n, Sqr (n - 84));
begin
  Pack (c, 1, d);
  Unpack (d, c, 1);
end;

begin
  AtExit (ExpectError);
  p (41)
end.
