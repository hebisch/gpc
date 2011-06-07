program fjf1044t;

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
  ta = t (42);

procedure q (a: ta);
begin
end;

procedure p (n: Integer);
var b: t (n);
begin
  q (b);
end;

begin
  AtExit (ExpectError);
  p (41)
end.
