program fjf1045h;

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
  u (a, b, c: Integer) = array [a .. b] of Integer;

procedure q1 (const a, b: t);
begin
end;

{$extended-pascal}

procedure p (n: Integer);
var
  a: t (42);
  b: t (n);
begin
  q1 (a, b)
end;

begin
  AtExit (ExpectError);
  p (41)
end.
