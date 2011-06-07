program fjf813b;

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
var q: 5 .. a;
begin
  WriteLn (SizeOf (q))
end;

begin
  AtExit (ExpectError);
  a := 2;
  Foo
end.
