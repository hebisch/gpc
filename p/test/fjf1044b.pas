program fjf1044b;

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
  a: array [1 .. 10] of t (42);
  b: packed array [21 .. 30] of t (n);
begin
  Pack (a, 1, b);
  Unpack (b, a, 1)
end;

begin
  AtExit (ExpectError);
  p (41)
end.
