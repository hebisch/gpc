program fjf1045a;

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
  te = String (3);

procedure q (var e: te);
begin
end;

procedure p (n: Integer);
var f: String (n - 2);
begin
  f := 'abc';
  q (f);
end;

begin
  AtExit (ExpectError);
  p (41)
end.
