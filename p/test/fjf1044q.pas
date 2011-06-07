program fjf1044q;

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

procedure f (n: Integer);
var
  f: file of u (42, 84, Sqr (42));
  d: u (n, 2 * n, Sqr (n - 84));
begin
  Rewrite (f);
  Write (f, d)
end;

begin
  AtExit (ExpectError);
  f (41)
end.
