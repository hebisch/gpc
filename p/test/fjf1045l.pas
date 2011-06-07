program fjf1045l;

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

procedure q1 (protected var e, f: String);
begin
end;

{$extended-pascal}

procedure p (n: Integer);
var
  e: String (40);
  f: String (n - 2);
begin
  e := 'abc';
  f := 'd';
  q1 (e, f)
end;

begin
  AtExit (ExpectError);
  p (41)
end.
