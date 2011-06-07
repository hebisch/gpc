program fjf222a;

uses GPC;

procedure x (a:Integer);
var c:array[4..a] of Integer;
begin
  c[4]:=0
end;

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

begin
  AtExit (ExpectError);
  x(1)
end.
