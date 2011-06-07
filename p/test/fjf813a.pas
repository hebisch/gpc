program fjf813a;

uses GPC;

var
  a: Integer;

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

procedure Foo;
var q: array [5 .. a] of Integer;
begin
  WriteLn (SizeOf (q))  { segfaults at runtime without range-checking }
end;

begin
  AtExit (ExpectError);
  a := 2;
  Foo
end.
